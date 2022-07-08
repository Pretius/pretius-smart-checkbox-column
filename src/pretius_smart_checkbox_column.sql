create or replace PACKAGE PRETIUS_SMART_CHECKBOX_COLUMN AS

FUNCTION f_render(
  p_dynamic_action in apex_plugin.t_dynamic_action,
  p_plugin         in apex_plugin.t_plugin 
) return apex_plugin.t_dynamic_action_render_result;

FUNCTION f_ajax( 
  p_dynamic_action IN apex_plugin.t_dynamic_action,
  p_plugin         IN apex_plugin.t_plugin
) return apex_plugin.t_dynamic_action_ajax_result;

END PRETIUS_SMART_CHECKBOX_COLUMN;

/

create or replace PACKAGE BODY          PRETIUS_SMART_CHECKBOX_COLUMN AS

FUNCTION f_render(
  p_dynamic_action in apex_plugin.t_dynamic_action,
  p_plugin         in apex_plugin.t_plugin 
) return apex_plugin.t_dynamic_action_render_result
IS 
  C_ATTR_SELECTION_SETTINGS CONSTANT p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;
  C_ATTR_COLUMN_NAME        CONSTANT p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;
  C_ATTR_STORAGE_ITEM       CONSTANT p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;
  C_ATTR_STORAGE_COLLECTION CONSTANT p_dynamic_action.attribute_04%type := NVL(p_dynamic_action.attribute_04, 'P'||V('APP_PAGE_ID')||'_SELECTED_VALUES');
  C_ATTR_VALUE_SEPARATOR    CONSTANT p_dynamic_action.attribute_05%type := NVL(p_dynamic_action.attribute_05, ':');
  C_ATTR_SELECTION_COLOR    CONSTANT p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;    
  C_ATTR_LIMIT_SELECTION    CONSTANT p_dynamic_action.attribute_07%type := NVL(p_dynamic_action.attribute_07, 'Y');
  C_ATTR_AUTO_SUBMIT_ITEM   CONSTANT p_dynamic_action.attribute_08%type := NVL(p_dynamic_action.attribute_08, 'N');  

  v_result                   apex_plugin.t_dynamic_action_render_result;
  
  v_dynamic_action_id        varchar2(100);
  v_region_id                varchar2(100);
  v_region_static_id         varchar2(100);
  v_region_template          varchar2(100);
  v_report_type              varchar2(100);
  v_report_template          varchar2(100);
  v_column_id                varchar2(100);
  v_css                      varchar2(4000);
  v_error                    varchar2(4000);

BEGIN
  IF apex_application.g_debug THEN
    apex_plugin_util.debug_dynamic_action (
      p_plugin         => p_plugin,
      p_dynamic_action => p_dynamic_action 
    );
  END IF;
  
  -- get region id associated with action
  BEGIN
    SELECT 
      AFFECTED_REGION_ID
    INTO
      v_region_id
    FROM 
      APEX_APPLICATION_PAGE_DA_ACTS 
    WHERE   
      ACTION_ID = p_dynamic_action.id;
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
      v_error := 'Pretius Smart Checkbox Column: Could not find affected report region. Contact application administrator.';
    WHEN TOO_MANY_ROWS THEN 
      v_error := 'Pretius Smart Checkbox Column: More than one affected report regions found. Contact application administrator.';
  END;

  -- get region/report inforamtions
  BEGIN
    SELECT 
      NVL(STATIC_ID, 'R'||REGION_ID) REGION_STATIC_ID,
      TEMPLATE, 
      CASE  SOURCE_TYPE
        WHEN 'Report' THEN 'Classic Report'
        ELSE SOURCE_TYPE
        END SOURCE_TYPE,
      REPORT_TEMPLATE 
    INTO 
      v_region_static_id,
      v_region_template,
      v_report_type,
      v_report_template
    FROM 
      APEX_APPLICATION_PAGE_REGIONS
    WHERE 
      REGION_ID = v_region_id;
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
      v_error := 'Pretius Smart Checkbox Column: Could not read report region details. Contact application administrator.';
    WHEN TOO_MANY_ROWS THEN 
      v_error := 'Pretius Smart Checkbox Column: Report region details ambiguously defined. Contact application administrator.';
  END;

  /* v_report_type - Report types:
  Report
  Interactive Report
  Interactive Grid
  Reflow Report
  Column Toggle Report
  */
  BEGIN
    CASE v_report_type
      WHEN 'Classic Report' THEN
        -- Classic report
        SELECT 
          NVL(STATIC_ID, COLUMN_ALIAS)
        INTO
          v_column_id
        FROM 
          APEX_APPLICATION_PAGE_RPT_COLS
        WHERE 
          REGION_ID = v_region_id
          AND COLUMN_ALIAS = C_ATTR_COLUMN_NAME;      
      WHEN 'Interactive Report' THEN
        -- Interactive report
        SELECT 
           NVL(STATIC_ID, 'C'||COLUMN_ID)
        INTO
          v_column_id     
        FROM 
          APEX_APPLICATION_PAGE_IR_COL
        WHERE 
          REGION_ID = v_region_id
          AND COLUMN_ALIAS  = C_ATTR_COLUMN_NAME;
      ELSE
        v_column_id := 'Not supported';
    END CASE;
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
      v_error := 'Pretius Smart Checkbox Column: '||C_ATTR_COLUMN_NAME||' column does not exist in affected report region. Contact application administrator.';
    WHEN TOO_MANY_ROWS THEN 
      v_error := 'Pretius Smart Checkbox Column: More than one '||C_ATTR_COLUMN_NAME||' column found. Contact application administrator.';
  END;
  
  APEX_JAVASCRIPT.ADD_LIBRARY (
    p_name      => 'smartCheckboxColumn',
    p_directory => p_plugin.file_prefix,
    p_version   => null 
  );

  IF C_ATTR_SELECTION_COLOR IS NOT NULL THEN
    v_css := '##region-static-id# tr.pscc-selected-row td { background-color: #selected-color#!important; }
              ##region-static-id# tr.pscc-selected-row:hover td { background-color: #selected-color#!important; } ';
    v_css := replace(v_css,'#selected-color#', C_ATTR_SELECTION_COLOR); 
    v_css := replace(v_css,'#region-static-id#', v_region_static_id);
    apex_css.add (
      p_css => v_css,
      p_key => 'smartCheckboxColumn'||v_region_static_id
    );
  END IF;
          
  v_result.ajax_identifier     := apex_plugin.get_ajax_identifier;     

  IF v_error IS NULL THEN     
    v_result.javascript_function := 
      'function(){ 
         $(this.affectedElements).smartCheckboxColumn( {'                                                            ||
            apex_javascript.add_attribute('ajaxIdentifier',             v_result.ajax_identifier)                     ||       
            apex_javascript.add_attribute('selectionSettings',          C_ATTR_SELECTION_SETTINGS)                    ||
            apex_javascript.add_attribute('columnName',                 APEX_ESCAPE.HTML(C_ATTR_COLUMN_NAME) )        ||
            apex_javascript.add_attribute('storageItemName',            C_ATTR_STORAGE_ITEM)                          ||
            apex_javascript.add_attribute('storageCollectionName',      APEX_ESCAPE.HTML(C_ATTR_STORAGE_COLLECTION) ) ||
            apex_javascript.add_attribute('valueSeparator',             APEX_ESCAPE.HTML(C_ATTR_VALUE_SEPARATOR) )    ||
            apex_javascript.add_attribute('selectionColor',             C_ATTR_SELECTION_COLOR)                       ||
            apex_javascript.add_attribute('limitSelection',             C_ATTR_LIMIT_SELECTION)                       ||
            apex_javascript.add_attribute('itemAutoSubmit',             C_ATTR_AUTO_SUBMIT_ITEM)                      ||          
            
            apex_javascript.add_attribute('regionId',                   v_region_static_id)                           ||          
            apex_javascript.add_attribute('regionTemplate',             v_region_template)                            ||
            apex_javascript.add_attribute('reportType',                 v_report_type )                               ||
            apex_javascript.add_attribute('reportTemplate',             v_report_template )                           ||  
            apex_javascript.add_attribute('columnId',                   v_column_id, false, false )                   ||          
          '});
        }';
  ELSE 
    v_result.javascript_function := 
      'function(){
        apex.message.clearErrors();
        apex.message.showErrors({
          type:       "error",
          location:   "page",
          message:    "' || v_error ||'",
          unsafe:     false
        });
      }';
  END IF;

  return v_result;
EXCEPTION
  WHEN OTHERS THEN 
    apex_error.add_error (
      p_message          => 'Pretius Smart Checkbox Column: Unidentified error occured. </br> 
                             SQLERRM: '|| SQLERRM || '</br> 
                             Contact application administrator.',
      p_display_location => apex_error.c_on_error_page  
    );

END f_render;

FUNCTION f_ajax( 
  p_dynamic_action IN apex_plugin.t_dynamic_action,
  p_plugin         IN apex_plugin.t_plugin
) return apex_plugin.t_dynamic_action_ajax_result
AS
  v_selected_values  APEX_APPLICATION_GLOBAL.VC_ARR2 DEFAULT APEX_APPLICATION.G_F01;
  v_ajax_command     varchar2(30)  DEFAULT APEX_APPLICATION.G_X01;
  v_save_to_coll     varchar2(30)  DEFAULT APEX_APPLICATION.G_X02;
  v_collection_name  varchar2(255) DEFAULT upper(APEX_APPLICATION.G_X03);
  v_collection_query varchar2(4000);
  v_ref_cur          sys_refcursor;
  v_result           apex_plugin.t_dynamic_action_ajax_result;
BEGIN

  --debug
  IF apex_application.g_debug THEN
    apex_plugin_util.debug_dynamic_action ( 
      p_plugin         => p_plugin,
      p_dynamic_action => p_dynamic_action
    );
  END IF;

  CASE upper(v_ajax_command)
    WHEN 'GET' THEN
      open v_ref_cur for 
        SELECT 
          C001 as "checkbox_value"
        FROM
          APEX_COLLECTIONS 
        WHERE 
          COLLECTION_NAME = v_collection_name;

      apex_json.open_object;      
        apex_json.write('selectedValues', v_ref_cur);
        apex_json.write('status', 'Ok');
        apex_json.write('message', 'Ok');      
      apex_json.close_object;
      --close v_ref_cur;

    WHEN 'SET' THEN
      IF upper(v_save_to_coll) = 'TRUE' THEN 
        APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION( v_collection_name );    
        APEX_COLLECTION.ADD_MEMBERS(
          p_collection_name => v_collection_name,
          p_c001            => v_selected_values
        );
      END IF;    

      apex_json.open_object;      
        apex_json.write('status', 'Ok');
        apex_json.write('message', 'APEX Collection updated successfully.');      
      apex_json.close_object;

    WHEN 'SUBMIT' THEN 
      apex_json.open_object;      
        apex_json.write('status', 'Ok');
        apex_json.write('message', 'APEX Item submitted successfully.');      
      apex_json.close_object;
    ELSE 
      apex_json.open_object;      
        apex_json.write('status', 'Ok');
        apex_json.write('message', 'No command for AJAX Callback.');      
      apex_json.close_object;
  END CASE;

  return v_result;

EXCEPTION
  WHEN OTHERS THEN
    apex_json.open_object; 
    apex_json.write('status', 'Error');
    apex_json.write('message', 'Error occured');           
    apex_json.write('SQLERRM', SQLERRM);
    apex_json.close_object;
    -- cleaning up
    apex_json.close_all;
    close v_ref_cur;
END f_ajax;

END PRETIUS_SMART_CHECKBOX_COLUMN;