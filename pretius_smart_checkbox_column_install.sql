prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_180100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2018.04.04'
,p_release=>'18.1.0.00.45'
,p_default_workspace_id=>1670328899049284
,p_default_application_id=>107
,p_default_owner=>'SMART_CB'
);
end;
/
prompt --application/shared_components/plugins/dynamic_action/pretius_smart_checkbox_column
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(11790640840733610)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'PRETIUS_SMART_CHECKBOX_COLUMN'
,p_display_name=>'Pretius Smart Checkbox Column'
,p_category=>'INIT'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'FUNCTION f_render(',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin         in apex_plugin.t_plugin ',
') return apex_plugin.t_dynamic_action_render_result',
'IS ',
'  C_ATTR_SELECTION_SETTINGS CONSTANT p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'  C_ATTR_COLUMN_NAME        CONSTANT p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'  C_ATTR_STORAGE_ITEM       CONSTANT p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'  C_ATTR_STORAGE_COLLECTION CONSTANT p_dynamic_action.attribute_04%type := NVL(p_dynamic_action.attribute_04, ''P''||V(''APP_PAGE_ID'')||''_SELECTED_VALUES'');',
'  C_ATTR_VALUE_SEPARATOR    CONSTANT p_dynamic_action.attribute_05%type := NVL(p_dynamic_action.attribute_05, '':'');',
'  C_ATTR_SELECTION_COLOR    CONSTANT p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;    ',
'  C_ATTR_LIMIT_SELECTION    CONSTANT p_dynamic_action.attribute_07%type := NVL(p_dynamic_action.attribute_07, ''Y'');',
'  C_ATTR_AUTO_SUBMIT_ITEM   CONSTANT p_dynamic_action.attribute_08%type := NVL(p_dynamic_action.attribute_08, ''N'');  ',
'',
'  v_result                   apex_plugin.t_dynamic_action_render_result;',
'  ',
'  v_dynamic_action_id        varchar2(100);',
'  v_region_id                varchar2(100);',
'  v_region_static_id         varchar2(100);',
'  v_region_template          varchar2(100);',
'  v_report_type              varchar2(100);',
'  v_report_template          varchar2(100);',
'  v_column_id                varchar2(100);',
'  v_css                      varchar2(4000);',
'  v_error                    varchar2(4000);',
'',
'BEGIN',
'  IF apex_application.g_debug THEN',
'    apex_plugin_util.debug_dynamic_action (',
'      p_plugin         => p_plugin,',
'      p_dynamic_action => p_dynamic_action ',
'    );',
'  END IF;',
'  ',
'  -- get region id associated with action',
'  BEGIN',
'    SELECT ',
'      AFFECTED_REGION_ID',
'    INTO',
'      v_region_id',
'    FROM ',
'      APEX_APPLICATION_PAGE_DA_ACTS ',
'    WHERE   ',
'      ACTION_ID = p_dynamic_action.id;',
'  EXCEPTION ',
'    WHEN NO_DATA_FOUND THEN ',
'      v_error := ''Pretius Smart Checkbox Column: Could not find affected report region. Contact application administrator.'';',
'    WHEN TOO_MANY_ROWS THEN ',
'      v_error := ''Pretius Smart Checkbox Column: More than one affected report regions found. Contact application administrator.'';',
'  END;',
'',
'  -- get region/report inforamtions',
'  BEGIN',
'    SELECT ',
'      NVL(STATIC_ID, ''R''||REGION_ID) REGION_STATIC_ID,',
'      TEMPLATE, ',
'      CASE  SOURCE_TYPE',
'        WHEN ''Report'' THEN ''Classic Report''',
'        ELSE SOURCE_TYPE',
'        END SOURCE_TYPE,',
'      REPORT_TEMPLATE ',
'    INTO ',
'      v_region_static_id,',
'      v_region_template,',
'      v_report_type,',
'      v_report_template',
'    FROM ',
'      APEX_APPLICATION_PAGE_REGIONS',
'    WHERE ',
'      REGION_ID = v_region_id;',
'  EXCEPTION ',
'    WHEN NO_DATA_FOUND THEN ',
'      v_error := ''Pretius Smart Checkbox Column: Could not read report region details. Contact application administrator.'';',
'    WHEN TOO_MANY_ROWS THEN ',
'      v_error := ''Pretius Smart Checkbox Column: Report region details ambiguously defined. Contact application administrator.'';',
'  END;',
'',
'  /* v_report_type - Report types:',
'  Report',
'  Interactive Report',
'  Interactive Grid',
'  Reflow Report',
'  Column Toggle Report',
'  */',
'  BEGIN',
'    CASE v_report_type',
'      WHEN ''Classic Report'' THEN',
'        -- Classic report',
'        SELECT ',
'          NVL(STATIC_ID, COLUMN_ALIAS)',
'        INTO',
'          v_column_id',
'        FROM ',
'          APEX_APPLICATION_PAGE_RPT_COLS',
'        WHERE ',
'          REGION_ID = v_region_id',
'          AND COLUMN_ALIAS = C_ATTR_COLUMN_NAME;      ',
'      WHEN ''Interactive Report'' THEN',
'        -- Interactive report',
'        SELECT ',
'           NVL(STATIC_ID, ''C''||COLUMN_ID)',
'        INTO',
'          v_column_id     ',
'        FROM ',
'          APEX_APPLICATION_PAGE_IR_COL',
'        WHERE ',
'          REGION_ID = v_region_id',
'          AND COLUMN_ALIAS  = C_ATTR_COLUMN_NAME;',
'      ELSE',
'        v_column_id := ''Not supported'';',
'    END CASE;',
'  EXCEPTION ',
'    WHEN NO_DATA_FOUND THEN ',
'      v_error := ''Pretius Smart Checkbox Column: ''||C_ATTR_COLUMN_NAME||'' column does not exist in affected report region. Contact application administrator.'';',
'    WHEN TOO_MANY_ROWS THEN ',
'      v_error := ''Pretius Smart Checkbox Column: More than one ''||C_ATTR_COLUMN_NAME||'' column found. Contact application administrator.'';',
'  END;',
'  ',
'  APEX_JAVASCRIPT.ADD_LIBRARY (',
'    p_name      => ''smartCheckboxColumn'',',
'    p_directory => p_plugin.file_prefix,',
'    p_version   => null ',
'  );',
'',
'  IF C_ATTR_SELECTION_COLOR IS NOT NULL THEN',
'    v_css := ''##region-static-id# tr.pscc-selected-row td { background-color: #selected-color#!important; }',
'              ##region-static-id# tr.pscc-selected-row:hover td { background-color: #selected-color#!important; } '';',
'    v_css := replace(v_css,''#selected-color#'', C_ATTR_SELECTION_COLOR); ',
'    v_css := replace(v_css,''#region-static-id#'', v_region_static_id);',
'    apex_css.add (',
'      p_css => v_css,',
'      p_key => ''smartCheckboxColumn''||v_region_static_id',
'    );',
'  END IF;',
'          ',
'  v_result.ajax_identifier     := apex_plugin.get_ajax_identifier;     ',
'',
'  IF v_error IS NULL THEN     ',
'    v_result.javascript_function := ',
'      ''function(){ ',
'         $(this.affectedElements).smartCheckboxColumn( {''                                                            ||',
'            apex_javascript.add_attribute(''ajaxIdentifier'',             v_result.ajax_identifier)                     ||       ',
'            apex_javascript.add_attribute(''selectionSettings'',          C_ATTR_SELECTION_SETTINGS)                    ||',
'            apex_javascript.add_attribute(''columnName'',                 APEX_ESCAPE.HTML(C_ATTR_COLUMN_NAME) )        ||',
'            apex_javascript.add_attribute(''storageItemName'',            C_ATTR_STORAGE_ITEM)                          ||',
'            apex_javascript.add_attribute(''storageCollectionName'',      APEX_ESCAPE.HTML(C_ATTR_STORAGE_COLLECTION) ) ||',
'            apex_javascript.add_attribute(''valueSeparator'',             APEX_ESCAPE.HTML(C_ATTR_VALUE_SEPARATOR) )    ||',
'            apex_javascript.add_attribute(''selectionColor'',             C_ATTR_SELECTION_COLOR)                       ||',
'            apex_javascript.add_attribute(''limitSelection'',             C_ATTR_LIMIT_SELECTION)                       ||',
'            apex_javascript.add_attribute(''itemAutoSubmit'',             C_ATTR_AUTO_SUBMIT_ITEM)                      ||          ',
'            ',
'            apex_javascript.add_attribute(''regionId'',                   v_region_static_id)                           ||          ',
'            apex_javascript.add_attribute(''regionTemplate'',             v_region_template)                            ||',
'            apex_javascript.add_attribute(''reportType'',                 v_report_type )                               ||',
'            apex_javascript.add_attribute(''reportTemplate'',             v_report_template )                           ||  ',
'            apex_javascript.add_attribute(''columnId'',                   v_column_id, false, false )                   ||          ',
'          ''});',
'        }'';',
'  ELSE ',
'    v_result.javascript_function := ',
'      ''function(){',
'        apex.message.clearErrors();',
'        apex.message.showErrors({',
'          type:       "error",',
'          location:   "page",',
'          message:    "'' || v_error ||''",',
'          unsafe:     false',
'        });',
'      }'';',
'  END IF;',
'',
'  return v_result;',
'EXCEPTION',
'  WHEN OTHERS THEN ',
'    apex_error.add_error (',
'      p_message          => ''Pretius Smart Checkbox Column: Unidentified error occured. </br> ',
'                             SQLERRM: ''|| SQLERRM || ''</br> ',
'                             Contact application administrator.'',',
'      p_display_location => apex_error.c_on_error_page  ',
'    );',
'',
'END f_render;',
'',
'FUNCTION f_ajax( ',
'  p_dynamic_action IN apex_plugin.t_dynamic_action,',
'  p_plugin         IN apex_plugin.t_plugin',
') return apex_plugin.t_dynamic_action_ajax_result',
'AS',
'  v_selected_values  APEX_APPLICATION_GLOBAL.VC_ARR2 DEFAULT APEX_APPLICATION.G_F01;',
'  v_ajax_command     varchar2(30)  DEFAULT APEX_APPLICATION.G_X01;',
'  v_save_to_coll     varchar2(30)  DEFAULT APEX_APPLICATION.G_X02;',
'  v_collection_name  varchar2(255) DEFAULT upper(APEX_APPLICATION.G_X03);',
'  v_collection_query varchar2(4000);',
'  v_ref_cur          sys_refcursor;',
'  v_result           apex_plugin.t_dynamic_action_ajax_result;',
'BEGIN',
'',
'  --debug',
'  IF apex_application.g_debug THEN',
'    apex_plugin_util.debug_dynamic_action ( ',
'      p_plugin         => p_plugin,',
'      p_dynamic_action => p_dynamic_action',
'    );',
'  END IF;',
'',
'  CASE upper(v_ajax_command)',
'    WHEN ''GET'' THEN',
'      open v_ref_cur for ',
'        SELECT ',
'          C001 as "checkbox_value"',
'        FROM',
'          APEX_COLLECTIONS ',
'        WHERE ',
'          COLLECTION_NAME = v_collection_name;',
'',
'      apex_json.open_object;      ',
'        apex_json.write(''selectedValues'', v_ref_cur);',
'        apex_json.write(''status'', ''Ok'');',
'        apex_json.write(''message'', ''Ok'');      ',
'      apex_json.close_object;',
'      --close v_ref_cur;',
'',
'    WHEN ''SET'' THEN',
'      IF upper(v_save_to_coll) = ''TRUE'' THEN ',
'        APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION( v_collection_name );    ',
'        APEX_COLLECTION.ADD_MEMBERS(',
'          p_collection_name => v_collection_name,',
'          p_c001            => v_selected_values',
'        );',
'      END IF;    ',
'',
'      apex_json.open_object;      ',
'        apex_json.write(''status'', ''Ok'');',
'        apex_json.write(''message'', ''APEX Collection updated successfully.'');      ',
'      apex_json.close_object;',
'',
'    WHEN ''SUBMIT'' THEN ',
'      apex_json.open_object;      ',
'        apex_json.write(''status'', ''Ok'');',
'        apex_json.write(''message'', ''APEX Item submitted successfully.'');      ',
'      apex_json.close_object;',
'    ELSE ',
'      apex_json.open_object;      ',
'        apex_json.write(''status'', ''Ok'');',
'        apex_json.write(''message'', ''No command for AJAX Callback.'');      ',
'      apex_json.close_object;',
'  END CASE;',
'',
'  return v_result;',
'',
'EXCEPTION',
'  WHEN OTHERS THEN',
'    apex_json.open_object; ',
'    apex_json.write(''status'', ''Error'');',
'    apex_json.write(''message'', ''Error occured'');           ',
'    apex_json.write(''SQLERRM'', SQLERRM);',
'    apex_json.close_object;',
'    -- cleaning up',
'    apex_json.close_all;',
'    close v_ref_cur;',
'END f_ajax;'))
,p_api_version=>2
,p_render_function=>'f_render'
,p_ajax_function=>'f_ajax'
,p_standard_attributes=>'REGION:REQUIRED:ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p> Use this plugin to change chosen report column to interactive checkbox column. </p>',
'<p> Configure the plugin to manage selection behavior and storage settings of selected values </b>'))
,p_version_identifier=>'1.0.0'
,p_about_url=>'https://github.com/Pretius/pretius-smart-checkbox-column'
,p_files_version=>5
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(11800633890748985)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Selection settings'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Select checkboxes to manage the plugin behavior.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(11810623150751022)
,p_plugin_attribute_id=>wwv_flow_api.id(11800633890748985)
,p_display_sequence=>10
,p_display_value=>'Store selected values in APEX Item'
,p_return_value=>'STORE_IN_ITEM'
,p_help_text=>'Checking this attribute will cause all selected values to be stored in APEX Item. Item needs to be provided in separate attribute ("APEX Item to store selected values").'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(11820643310752240)
,p_plugin_attribute_id=>wwv_flow_api.id(11800633890748985)
,p_display_sequence=>20
,p_display_value=>'Store selected values in APEX Collection'
,p_return_value=>'STORE_IN_COLLECTION'
,p_help_text=>'Checking this attribute will cause all selected values to be stored in APEX collection. Collection name can be defined in separate attribute ("APEX Collection name to store selected values"). Default collection name is PX_SELECTED_VALUES where X is a'
||'n application page number where the plugin instance exists. It is recommanded to change the defalut value, especially when there are more than one plugin instance existing on the same page.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(11830599836754130)
,p_plugin_attribute_id=>wwv_flow_api.id(11800633890748985)
,p_display_sequence=>30
,p_display_value=>'Allow multiple selection'
,p_return_value=>'ALLOW_MULTIPLE'
,p_help_text=>'Check this attribute to allow for selecting mutliple rows at once. When this checkbox is left empty, only one row can be selected at the same time and checkbox in the header is disabled.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(11840614729755612)
,p_plugin_attribute_id=>wwv_flow_api.id(11800633890748985)
,p_display_sequence=>40
,p_display_value=>'Select with click on row'
,p_return_value=>'SELECT_ON_ROW_CLICK'
,p_help_text=>'Check this attribute to allow for selecting checkboxes when clicked anywhere on a row.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(11850609718763062)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Column name to be replaced'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>128
,p_is_translatable=>false
,p_text_case=>'UPPER'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p><ul>',
'  <li> EMPLOYEE_ID </li>',
'  <li> ROWID </li>',
'</ul></p>'))
,p_help_text=>'Provide a name of the report column that will be used to render checkboxes. All the text that column cells contain will be placed in a checkbox value attribute. The attribute is used to handle selection state. In most cases column should contain uniq'
||'ue values.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(11860674117766873)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'APEX Item to store selected values'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(11800633890748985)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Application page item that will be used to store currently selected row(s). Selection is stored as text and values are separated with character defined in attribute "Value separator" (default ":"). </p>',
'<p>Because of maximum value length of APEX items, you may want Pretius Smart checkbox plugin to prevent from exceeding this limit. In this case make sure that "Limit selection length to 4000 Bytes" attribute is set to "Yes". </p>',
'<p> Use "Auto submit storage item" to automatically submit item value to APEX session state. </p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(11870589054769818)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'APEX Collection name to store selected values'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(11800633890748985)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_COLLECTION'
,p_text_case=>'UPPER'
,p_help_text=>'Specify name of APEX collection that will be used to store currently selected row(s). Each selected row value is stored in separate collection member in varchar2 column "C001". Default collection name is PX_SELECTED_VALUES where X is an application p'
||'age number where the plugin instance exists. It is recommanded to change the defalut value, especially when there is more than one plugin instance existing on the same page.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(11870902259772904)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>60
,p_prompt=>'Value separator'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_common=>false
,p_default_value=>':'
,p_max_length=>5
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(11800633890748985)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p> Separator for subsequent selected values when stored in APEX item. Default separator is ":". </p>',
'<p> Maximum length of separator is 5 characters. </p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(11880677298779088)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>50
,p_prompt=>'Selection color'
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p><ul>',
'  <li> #ff0000 </li>',
'  <li> rgb(0,127,0) </li>',
'  <li> rgba(0,0,0,0.8) </li>',
'  <li> hsl(195, 100%, 50%) </li>',
'  <li> hsla(195, 100%, 50%, 0.2) </li>',
'  <li> transparent </li>',
'  <li> black </li>',
'</ul></p>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>',
'  Color that will be applied for the background of selected rows. If you do not like to use any color leave this field blank. Color can be entered by using build-in color picker, but field accept all valid color formats for CSS3:',
'  <ul>',
'    <li> Hexadecimal red-green-blue </li>',
'    <li> rgb()	Functional red-green-blue </li>',
'    <li> rgba()	Functional red-green-blue with alpha </li>',
'    <li> hsl()	Hue-saturation-lightness </li>',
'    <li> hsla()	Hue-saturation-lightness with alpha </li>',
'    <li> Color keyword </li>',
'  </ul>',
'</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(14270994051186690)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Limit selection length to 4000 Bytes'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_is_common=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(11800633890748985)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>'Because of maximum value length of APEX items, you may want Pretius Smart checkbox plugin to prevent from exceeding this limit. In this case set this attribute is set to "Yes". When the limit is reached, all selected values above the limit will be tr'
||'uncated and plugin will trigger an event "Maximum selection length exceeded".'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(14430474033056009)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Auto submit storage item'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_is_common=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(11800633890748985)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>'Set this attribute to "Yes" to automatically submit item value to APEX session state anytime selection is changed.'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(14400483053953158)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_name=>'max_selection_length_exceeded'
,p_display_name=>'Maximum selection length exceeded'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0D0A2A20506C7567696E3A205072657469757320536D61727420636865636B626F7820636F6C756D6E0D0A2A2056657273696F6E3A20312E302E300D0A2A0D0A2A20417574686F723A204164616D204B6965727A6B6F77736B690D0A2A204D61696C';
wwv_flow_api.g_varchar2_table(2) := '3A20616B6965727A6B6F77736B6940707265746975732E636F6D0D0A2A20547769747465723A206B6965727A6B6F77736B6934390D0A2A20426C6F673A200D0A2A0D0A2A20446570656E64733A0D0A2A20202020617065782F64656275672E6A730D0A2A';
wwv_flow_api.g_varchar2_table(3) := '0D0A2A204368616E6765733A0D0A2A0D0A2A2F0D0A0D0A2866756E6374696F6E202864656275672C2024297B0D0A20202275736520737472696374223B0D0A0D0A2020242E776964676574282022707265746975732E736D617274436865636B626F7843';
wwv_flow_api.g_varchar2_table(4) := '6F6C756D6E222C207B0D0A202020202F2F20636F6E7374616E74730D0A20202020435F504C5547494E5F4E414D452020202020203A20275072657469757320536D61727420636865636B626F7820636F6C756D6E272C0D0A20202020435F4C4F475F5052';
wwv_flow_api.g_varchar2_table(5) := '45464958202020202020203A2027536D61727420636865636B626F7820636F6C756D6E3A20272C0D0A20202020435F4C4F475F4C564C5F4552524F52202020203A2064656275672E4C4F475F4C4556454C2E4552524F522C2020202020202020202F2F20';
wwv_flow_api.g_varchar2_table(6) := '76616C756520312028656E642D757365722920200D0A20202020435F4C4F475F4C564C5F5741524E494E4720203A2064656275672E4C4F475F4C4556454C2E5741524E2C202020202020202020202F2F2076616C756520322028646576656C6F70657229';
wwv_flow_api.g_varchar2_table(7) := '0D0A20202020435F4C4F475F4C564C5F4445425547202020203A2064656275672E4C4F475F4C4556454C2E494E464F2C202020202020202020202F2F2076616C7565203420286465627567290D0A20202020435F4C4F475F4C564C5F3620202020202020';
wwv_flow_api.g_varchar2_table(8) := '203A2064656275672E4C4F475F4C4556454C2E4150505F54524143452C20202020202F2F2076616C75652036200D0A20202020435F4C4F475F4C564C5F3920202020202020203A2064656275672E4C4F475F4C4556454C2E454E47494E455F5452414345';
wwv_flow_api.g_varchar2_table(9) := '2C20202F2F2076616C756520390D0A0D0A20202020435F535550504F525445445F5245504F52545F545950455320202020202020203A205B27436C6173736963205265706F7274272C2027496E746572616374697665205265706F7274275D2C0D0A2020';
wwv_flow_api.g_varchar2_table(10) := '2020435F444953504C41595F504147455F4552524F525F4D455353414745532020203A20747275652C0D0A20202020435F454E445F555345525F4552524F525F5052454649582020202020202020203A2027436865636B626F782066756E6374696F6E61';
wwv_flow_api.g_varchar2_table(11) := '6C697479206572726F723A20272C0D0A20202020435F454E445F555345525F4552524F525F5355464649582020202020202020203A2027436F6E7461637420796F75722061646D696E6973747261746F722E272C0D0A20202020435F4552524F525F5245';
wwv_flow_api.g_varchar2_table(12) := '504F52545F4E4F545F535550504F52544544202020203A202743686F73656E20726567696F6E206973206E6F742061207265706F7274206F7220746865207265706F72742074797065206973206E6F7420737570706F727465642E20272C0D0A20202020';
wwv_flow_api.g_varchar2_table(13) := '435F4552524F525F4E4F5F434F4C554D4E5F464F554E442020202020202020203A20275265706F727420636F6C756D6E20746F20646973706C617920636865636B626F78657320646F6573206E6F742065786973742E20272C0D0A20202020435F455252';
wwv_flow_api.g_varchar2_table(14) := '4F525F434845434B424F5845535F444F5F4E4F545F4558495354203A20274E6F20636865636B626F7865732065786973742E20272C0D0A20202020435F4552524F525F4954454D5F444F45535F4E4F545F455849535420202020203A2027415045582069';
wwv_flow_api.g_varchar2_table(15) := '74656D2063686F73656E20746F2073746F72652073656C65637465642076616C75657320646F6573206E6F742065786973742E20272C0D0A20202020435F4552524F525F414A41585F53544F52455F4641494C5552452020202020203A202753746F7269';
wwv_flow_api.g_varchar2_table(16) := '6E672063757272656E746C792073656C656374656420726F777320686173206661696C65642E20272C0D0A20202020435F4552524F525F414A41585F524541445F4641494C555245202020202020203A202752656164696E672063757272656E746C7920';
wwv_flow_api.g_varchar2_table(17) := '73656C656374656420726F777320686173206661696C65642E20272C0D0A20202020435F53454C45435445445F524F575F434C4153532020202020202020202020203A2027707363632D73656C65637465642D726F77272C0D0A20202020435F53544F52';
wwv_flow_api.g_varchar2_table(18) := '4147455F4954454D5F4D41585F42595445535F434F554E5420203A20343030302C0D0A20202020435F4556454E545F4D41585F53454C454354494F4E5F455843454445442020203A20276D61785F73656C656374696F6E5F6C656E6774685F6578636565';
wwv_flow_api.g_varchar2_table(19) := '646564272C0D0A0D0A202020206F7074696F6E733A207B0D0A202020207D2C0D0A0D0A0D0A202020202F2F206372656174652066756E6374696F6E0D0A202020205F6372656174653A2066756E6374696F6E28297B0D0A2020202020207661722073656C';
wwv_flow_api.g_varchar2_table(20) := '66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20275374617274696E672077696467657420696E697469616C697A6174';
wwv_flow_api.g_varchar2_table(21) := '696F6E2E2E2E272C20276F7074696F6E733A20272C2073656C662E6F7074696F6E73293B0D0A20202020202073656C662E7265706F727450726F70657274696573203D207B0D0A202020202020202022726567696F6E49642220202020202020203A2073';
wwv_flow_api.g_varchar2_table(22) := '656C662E6F7074696F6E732E726567696F6E49642C0D0A202020202020202022726567696F6E54656D706C6174652220203A2073656C662E6F7074696F6E732E726567696F6E54656D706C6174652C0D0A2020202020202020227265706F727454797065';
wwv_flow_api.g_varchar2_table(23) := '222020202020203A2073656C662E6F7074696F6E732E7265706F7274547970652C0D0A2020202020202020227265706F727454656D706C6174652220203A2073656C662E6F7074696F6E732E7265706F727454656D706C6174652C20202020202020200D';
wwv_flow_api.g_varchar2_table(24) := '0A2020202020207D3B0D0A20202020202073656C662E636F6C756D6E50726F70657274696573203D207B0D0A202020202020202022636F6C756D6E4E616D65222020202020203A2073656C662E6F7074696F6E732E636F6C756D6E4E616D652C0D0A2020';
wwv_flow_api.g_varchar2_table(25) := '20202020202022636F6C756D6E49642220202020202020203A2073656C662E6F7074696F6E732E636F6C756D6E49642C202020202020200D0A2020202020207D3B0D0A20202020202073656C662E73656C656374696F6E50726F70657274696573203D20';
wwv_flow_api.g_varchar2_table(26) := '7B0D0A202020202020202022616C6C6F774D756C7469706C6553656C656374696F6E22202020203A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C65';
wwv_flow_api.g_varchar2_table(27) := '6374696F6E53657474696E67732E696E6465784F662827414C4C4F575F4D554C5449504C452729203E202D312C0D0A20202020202020202273656C6563744F6E436C69636B416E7977686572652220202020203A2073656C662E6F7074696F6E732E7365';
wwv_flow_api.g_varchar2_table(28) := '6C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F66282753454C4543545F4F4E5F524F575F434C49434B2729203E202D312C0D0A20202020';
wwv_flow_api.g_varchar2_table(29) := '202020202273656C656374696F6E436F6C6F72222020202020202020202020203A2073656C662E6F7074696F6E732E73656C656374696F6E436F6C6F720D0A2020202020207D3B0D0A20202020202073656C662E73746F7261676550726F706572746965';
wwv_flow_api.g_varchar2_table(30) := '73203D207B0D0A20202020202020202273746F726553656C6563746564496E4974656D22202020202020203A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(31) := '73656C656374696F6E53657474696E67732E696E6465784F66282753544F52455F494E5F4954454D2729203E202D312C0D0A20202020202020202273746F726553656C6563746564496E436F6C6C656374696F6E22203A2073656C662E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(32) := '2E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F66282753544F52455F494E5F434F4C4C454354494F4E2729203E202D312C202020';
wwv_flow_api.g_varchar2_table(33) := '20202020200D0A20202020202020202273746F726167654974656D4E616D652220202020202020202020203A2073656C662E6F7074696F6E732E73746F726167654974656D4E616D652C0D0A2020202020202020226974656D4175746F5375626D697422';
wwv_flow_api.g_varchar2_table(34) := '2020202020202020202020203A2073656C662E6F7074696F6E732E6974656D4175746F5375626D6974203D3D3D20275927203F2074727565203A2066616C73652C0D0A20202020202020202273746F72616765436F6C6C656374696F6E4E616D65222020';
wwv_flow_api.g_varchar2_table(35) := '2020203A2073656C662E6F7074696F6E732E73746F72616765436F6C6C656374696F6E4E616D652C0D0A20202020202020202276616C7565536570617261746F72222020202020202020202020203A2073656C662E6F7074696F6E732E76616C75655365';
wwv_flow_api.g_varchar2_table(36) := '70617261746F722C0D0A2020202020202020226C696D697453656C656374696F6E222020202020202020202020203A2073656C662E6F7074696F6E732E6C696D697453656C656374696F6E20200D0A2020202020207D3B0D0A0D0A202020202020696620';
wwv_flow_api.g_varchar2_table(37) := '2873656C662E5F636865636B49665265706F727454797065537570706F727465642829203D3D2066616C7365297B0D0A202020202020202073656C662E5F7468726F774572726F7228275F637265617465272C2073656C662E435F4552524F525F524550';
wwv_flow_api.g_varchar2_table(38) := '4F52545F4E4F545F535550504F525445442C2074727565293B0D0A2020202020207D0D0A2020202020206966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D203D3D207472756520262620';
wwv_flow_api.g_varchar2_table(39) := '73656C662E5F636865636B49664974656D4578697374732829203D3D2066616C7365297B0D0A202020202020202073656C662E5F7468726F774572726F7228275F637265617465272C2073656C662E435F4552524F525F4954454D5F444F45535F4E4F54';
wwv_flow_api.g_varchar2_table(40) := '5F45584953542C2066616C7365293B0D0A2020202020207D0D0A2020202020200D0A2020202020202F2F20544F20444F202D2068616E646C6520646966666572656E7420636C6173736963207265706F72742074656D706C617465730D0A202020202020';
wwv_flow_api.g_varchar2_table(41) := '2F2F20544F20444F202D2068616E646C6520646966666572656E74207265706F72742074797065730D0A0D0A20202020202073656C662E726567696F6E24203D2024282723272B73656C662E7265706F727450726F706572746965732E726567696F6E49';
wwv_flow_api.g_varchar2_table(42) := '64293B0D0A0D0A20202020202073656C662E726567696F6E242E6F6E282761706578616674657272656672657368272C2066756E6374696F6E202829207B0D0A202020202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C';
wwv_flow_api.g_varchar2_table(43) := '5F44454255472C2073656C662E435F4C4F475F5052454649582C2027416674657220726566726573682070726F63657373696E672E2E2E2027293B0D0A202020202020202073656C662E5F66696E64436865636B626F78436F6C756D6E28293B0D0A2020';
wwv_flow_api.g_varchar2_table(44) := '20202020202073656C662E5F72656E646572436865636B626F78657328293B0D0A202020202020202073656C662E5F616464436C69636B4C697374656E65727328293B0D0A202020202020202073656C662E5F6170706C7953656C656374696F6E28293B';
wwv_flow_api.g_varchar2_table(45) := '0D0A2020202020207D293B0D0A0D0A20202020202073656C662E5F66696E64436865636B626F78436F6C756D6E28293B0D0A20202020202073656C662E5F72656E646572436865636B626F78657328293B0D0A20202020202073656C662E5F616464436C';
wwv_flow_api.g_varchar2_table(46) := '69636B4C697374656E65727328293B20202020200D0A20202020202073656C662E5F67657453746F72656456616C75657328293B0D0A2020202020200D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F444542';
wwv_flow_api.g_varchar2_table(47) := '55472C2073656C662E435F4C4F475F5052454649582C202757696467657420696E697469616C697A6564207375636365737366756C6C793A2027293B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F444542';
wwv_flow_api.g_varchar2_table(48) := '55472C2073656C662E435F4C4F475F5052454649582C20275265706F72743A20272C2073656C662E726567696F6E24293B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F';
wwv_flow_api.g_varchar2_table(49) := '4C4F475F5052454649582C20274865616465723A20272C2073656C662E636F6C756D6E48656164657224293B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F50';
wwv_flow_api.g_varchar2_table(50) := '52454649582C202743656C6C733A2027202C2073656C662E636F6C756D6E43656C6C7324293B2020202020200D0A202020207D2C0D0A20200D0A202020202F2F206A5175657279207769646765742070726976617465206D6574686F64730D0A0D0A2020';
wwv_flow_api.g_varchar2_table(51) := '20205F636865636B49665265706F727454797065537570706F727465643A2066756E6374696F6E28297B0D0A2020202020207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C';
wwv_flow_api.g_varchar2_table(52) := '564C5F362C2073656C662E435F4C4F475F5052454649582C2027436865636B696E67206966207265706F7274207479706520697320737570706F727465642E2E2E27293B0D0A0D0A20202020202072657475726E2073656C662E435F535550504F525445';
wwv_flow_api.g_varchar2_table(53) := '445F5245504F52545F54595045532E696E636C756465732873656C662E7265706F727450726F706572746965732E7265706F727454797065293B20202020200D0A202020207D2C0D0A0D0A202020205F636865636B49664974656D4578697374733A2066';
wwv_flow_api.g_varchar2_table(54) := '756E6374696F6E28297B0D0A2020202020207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C2027436865636B69';
wwv_flow_api.g_varchar2_table(55) := '6E672069662061706578206974656D206578697374732E2E2E27293B0D0A0D0A20202020202072657475726E20617065782E6974656D2873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D65292E6E6F64653B';
wwv_flow_api.g_varchar2_table(56) := '20202020200D0A202020207D2C0D0A0D0A202020205F66696E64436865636B626F78436F6C756D6E3A2066756E6374696F6E28297B0D0A2020202020207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873';
wwv_flow_api.g_varchar2_table(57) := '656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202746696E64696E6720636865636B626F7820636F6C756D6E2E2E2E27293B0D0A0D0A2020202020200D0A20202020202073656C662E636F6C756D6E4865616465';
wwv_flow_api.g_varchar2_table(58) := '7224203D2073656C662E726567696F6E242E66696E642827746823272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E4964293B0D0A20202020202073656C662E636F6C756D6E43656C6C732420203D2073656C662E726567696F';
wwv_flow_api.g_varchar2_table(59) := '6E242E66696E64282774645B686561646572733D22272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E49642B27225D27293B0D0A202020207D2C0D0A0D0A202020202F2F2046756E6374696F6E2072656E646572732063686563';
wwv_flow_api.g_varchar2_table(60) := '6B626F78657320617661696C61626C6520616674657220696E2073656C662E63656C6C43686563626F7865732420616E642073656C662E686561646572436865636B626F78240D0A202020205F72656E646572436865636B626F7865733A2066756E6374';
wwv_flow_api.g_varchar2_table(61) := '696F6E28297B0D0A2020202020207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202752656E646572696E6720';
wwv_flow_api.g_varchar2_table(62) := '636865636B626F7865732E2E2E27293B0D0A2020202020200D0A2020202020202F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(63) := '2D2D202A2F0D0A2020202020202F2A20436F6D6D656E746564206F7574202D207265706F72742063616E2068617665206E6F20726573756C747320696E20616E792074696D65206F6620612072756E74696D65202A2F0D0A2020202020202F2A0D0A2020';
wwv_flow_api.g_varchar2_table(64) := '202020202F2F20436865636B20696620636F6C756D6E20746F207375627374697475746520697320646566696E65640D0A2020202020206966202873656C662E636F6C756D6E43656C6C73242E6C656E677468203D3D2030297B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(65) := '73656C662E5F7468726F774572726F7228275F72656E646572436865636B626F786573272C2073656C662E435F4552524F525F4E4F5F434F4C554D4E5F464F554E442C2074727565293B0D0A202020202020202072657475726E3B0D0A2020202020207D';
wwv_flow_api.g_varchar2_table(66) := '0D0A2020202020202A2F0D0A0D0A2020202020202F2F2072656E646572696E6720636F6C756D6E20636865636B626F7865730D0A20202020202073656C662E636F6C756D6E43656C6C73242E656163682866756E6374696F6E28297B0D0A202020202020';
wwv_flow_api.g_varchar2_table(67) := '20206C6574200D0A2020202020202020202063656C6C242020202020202020202020203D20242874686973292C0D0A2020202020202020202063656C6C56616C756520202020202020203D2063656C6C242E7465787428292C0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(68) := '2076616C75654174747269627574652020203D20272076616C75653D22272B63656C6C56616C75652B272220272C0D0A202020202020202020202F2F20544F20444F202D20637573746F6D697A6F77616E792063622C206163636573736962696C697479';
wwv_flow_api.g_varchar2_table(69) := '0D0A20202020202020202020636865636B626F782420202020202020203D202428273C696E70757420747970653D22636865636B626F7822272B2076616C7565417474726962757465202B273E27293B0D0A202020202020202020200D0A202020202020';
wwv_flow_api.g_varchar2_table(70) := '202063656C6C242E68746D6C28636865636B626F7824293B0D0A2020202020207D293B0D0A20202020202073656C662E63656C6C43686563626F78657324203D2073656C662E636F6C756D6E43656C6C73242E66696E642827696E7075745B747970653D';
wwv_flow_api.g_varchar2_table(71) := '22636865636B626F78225D27293B0D0A0D0A2020202020202F2F2072656E646572696E672068656164657220636865636B626F780D0A2020202020207661720D0A202020202020202064697361626C656441747472696275746520203D202173656C662E';
wwv_flow_api.g_varchar2_table(72) := '73656C656374696F6E50726F706572746965732E616C6C6F774D756C7469706C6553656C656374696F6E203F20272064697361626C65642027203A2027272C0D0A2020202020202020686561646572436865636B626F7824202020203D202428273C696E';
wwv_flow_api.g_varchar2_table(73) := '70757420747970653D22636865636B626F7822272B2064697361626C65644174747269627574652B273E27293B0D0A2020202020200D0A20202020202073656C662E636F6C756D6E486561646572242E66696E6428276127292E72656D6F766528293B0D';
wwv_flow_api.g_varchar2_table(74) := '0A20202020202073656C662E636F6C756D6E486561646572242E66696E6428277370616E27292E72656D6F766528293B0D0A20202020202073656C662E636F6C756D6E486561646572242E636F6E74656E747328292E66696C7465722866756E6374696F';
wwv_flow_api.g_varchar2_table(75) := '6E2829207B0D0A202020202020202072657475726E20746869732E6E6F646554797065203D3D204E6F64652E544558545F4E4F44453B0D0A2020202020207D292E72656D6F766528293B202020200D0A0D0A20202020202073656C662E636F6C756D6E48';
wwv_flow_api.g_varchar2_table(76) := '6561646572242E617070656E6428686561646572436865636B626F7824293B0D0A20202020202073656C662E686561646572436865636B626F7824203D20686561646572436865636B626F78243B0D0A202020207D2C0D0A0D0A202020205F616464436C';
wwv_flow_api.g_varchar2_table(77) := '69636B4C697374656E6572733A2066756E6374696F6E28297B0D0A2020202020207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F';
wwv_flow_api.g_varchar2_table(78) := '5052454649582C2027416464696E6720636C69636B206C697374656E6572732E2E2E27293B0D0A0D0A2020202020202F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(79) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A2020202020202F2A20436F6D6D656E746564206F7574202D207265706F72742063616E2068617665206E6F20726573756C747320696E20616E792074696D65206F6620612072756E74696D65202A';
wwv_flow_api.g_varchar2_table(80) := '2F0D0A2020202020202F2A0D0A2020202020202F2F20436865636B20696620636865636B626F7865732065786973740D0A2020202020206966202873656C662E63656C6C43686563626F786573242E6C656E677468203D3D2030297B0D0A202020202020';
wwv_flow_api.g_varchar2_table(81) := '202073656C662E5F7468726F774572726F7228275F616464436C69636B4C697374656E657273272C2073656C662E435F4552524F525F434845434B424F5845535F444F5F4E4F545F45584953542C2074727565293B0D0A20202020202020207265747572';
wwv_flow_api.g_varchar2_table(82) := '6E3B0D0A2020202020207D200D0A2020202020202A2F0D0A0D0A2020202020202F2F204164642063656C6C20636865636B626F78206C697374656E6572730D0A20202020202073656C662E63656C6C43686563626F786573242E656163682866756E6374';
wwv_flow_api.g_varchar2_table(83) := '696F6E28297B0D0A20202020202020206C6574200D0A20202020202020202020636865636B626F7824203D20242874686973292C0D0A20202020202020202020706172656E74526F77203D20242874686973292E636C6F736573742827747227293B0D0A';
wwv_flow_api.g_varchar2_table(84) := '0D0A20202020202020206966202873656C662E73656C656374696F6E50726F706572746965732E73656C6563744F6E436C69636B416E797768657265297B0D0A202020202020202020206966202873656C662E73656C656374696F6E50726F7065727469';
wwv_flow_api.g_varchar2_table(85) := '65732E616C6C6F774D756C7469706C6553656C656374696F6E297B0D0A202020202020202020202020706172656E74526F772E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F6D756C7469706C6553656C656374696F6E48616E646C';
wwv_flow_api.g_varchar2_table(86) := '65722C2073656C662C20636865636B626F782429293B202F2F2032202D20726F772073656C656374696F6E2C206D756C7469706C650D0A202020202020202020207D20656C7365207B0D0A202020202020202020202020706172656E74526F772E6F6E28';
wwv_flow_api.g_varchar2_table(87) := '27636C69636B272C20242E70726F7879282073656C662E5F73696E676C6553656C656374696F6E48616E646C65722C2073656C662C20636865636B626F782429293B2020202F2F2031202D20726F772073656C656374696F6E2C2073696E676C650D0A20';
wwv_flow_api.g_varchar2_table(88) := '2020202020202020207D200D0A20202020202020207D20656C7365207B0D0A202020202020202020206966202873656C662E73656C656374696F6E50726F706572746965732E616C6C6F774D756C7469706C6553656C656374696F6E297B0D0A20202020';
wwv_flow_api.g_varchar2_table(89) := '2020202020202020636865636B626F78242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F6D756C7469706C6553656C656374696F6E48616E646C65722C2073656C662C20636865636B626F782429293B2020202F2F2033202D2063';
wwv_flow_api.g_varchar2_table(90) := '6865636B626F782073656C656369746F6E2C2073696E676C650D0A202020202020202020207D20656C7365207B0D0A202020202020202020202020636865636B626F78242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73696E67';
wwv_flow_api.g_varchar2_table(91) := '6C6553656C656374696F6E48616E646C65722C2073656C662C20636865636B626F782429293B202F2F2034202D20636865636B626F782073656C656374696F6E2C206D756C7469706C652020200D0A202020202020202020207D0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(92) := '7D0D0A2020202020207D293B200D0A2020202020200D0A2020202020202F2F204164642068656164657220636865636B626F78206C697374656E65720D0A2020202020206966202873656C662E73656C656374696F6E50726F706572746965732E616C6C';
wwv_flow_api.g_varchar2_table(93) := '6F774D756C7469706C6553656C656374696F6E297B0D0A20202020202020206966202873656C662E73656C656374696F6E50726F706572746965732E73656C6563744F6E436C69636B416E797768657265297B0D0A2020202020202020202073656C662E';
wwv_flow_api.g_varchar2_table(94) := '636F6C756D6E486561646572242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73656C656374416C6C48616E646C65722C2073656C6629293B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202073656C66';
wwv_flow_api.g_varchar2_table(95) := '2E686561646572436865636B626F78242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73656C656374416C6C48616E646C65722C2073656C6629293B0D0A20202020202020207D0D0A2020202020207D0D0A202020207D2C0D0A0D';
wwv_flow_api.g_varchar2_table(96) := '0A202020205F73696E676C6553656C656374696F6E48616E646C65723A2066756E6374696F6E2870436865636B626F78242C20704576656E74297B0D0A202020202020766172200D0A202020202020202073656C6620203D20746869732C0D0A20202020';
wwv_flow_api.g_varchar2_table(97) := '2020202076616C7565203D2070436865636B626F78242E76616C28293B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202753696E676C6520';
wwv_flow_api.g_varchar2_table(98) := '73656C656374696F6E2068616E646C657220747269676765726564206279206576656E743A20272C20704576656E74293B0D0A2020202020200D0A0D0A2020202020206966202873656C662E73656C656374656456616C7565732E696E636C7564657328';
wwv_flow_api.g_varchar2_table(99) := '76616C75652929207B0D0A202020202020202073656C662E5F636C65617253656C656374656456616C75657328293B0D0A2020202020207D20656C7365207B0D0A202020202020202073656C662E5F636C65617253656C656374656456616C7565732829';
wwv_flow_api.g_varchar2_table(100) := '3B0D0A202020202020202073656C662E5F616464546F53656C656374656456616C7565732876616C7565293B0D0A2020202020207D0D0A0D0A20202020202073656C662E5F6170706C7953656C656374696F6E28293B0D0A20202020202073656C662E5F';
wwv_flow_api.g_varchar2_table(101) := '73746F726556616C75657328293B20200D0A202020207D2C0D0A0D0A202020205F6D756C7469706C6553656C656374696F6E48616E646C65723A2066756E6374696F6E2870436865636B626F78242C20704576656E74297B0D0A20202020202076617220';
wwv_flow_api.g_varchar2_table(102) := '0D0A202020202020202073656C6620203D20746869732C0D0A202020202020202076616C7565203D2070436865636B626F78242E76616C28293B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F4445425547';
wwv_flow_api.g_varchar2_table(103) := '2C2073656C662E435F4C4F475F5052454649582C20274D756C7469706C652073656C656374696F6E2068616E646C657220747269676765726564206279206576656E743A20272C20704576656E74293B0D0A0D0A2020202020206966202873656C662E73';
wwv_flow_api.g_varchar2_table(104) := '656C656374656456616C7565732E696E636C756465732876616C75652929207B0D0A202020202020202073656C662E5F72656D6F766546726F6D53656C656374656456616C7565732876616C7565293B0D0A2020202020207D20656C7365207B0D0A2020';
wwv_flow_api.g_varchar2_table(105) := '20202020202073656C662E5F616464546F53656C656374656456616C7565732876616C7565293B0D0A2020202020207D2020202020200D0A20202020202073656C662E5F6170706C7953656C656374696F6E28293B0D0A20202020202073656C662E5F73';
wwv_flow_api.g_varchar2_table(106) := '746F726556616C75657328293B200D0A202020207D2C20200D0A0D0A202020205F73656C656374416C6C48616E646C65723A2066756E6374696F6E28704576656E74297B0D0A2020202020207661722073656C66203D20746869733B0D0A202020202020';
wwv_flow_api.g_varchar2_table(107) := '64656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202753656C65637420616C6C2068616E646C657220747269676765726564206279206576656E743A20272C207045';
wwv_flow_api.g_varchar2_table(108) := '76656E74293B20200D0A0D0A2020202020202F2F20696620636C69636B20776173206E6F7420696E2074686520636865636B626F782C206265636175736520636865636B626F782077696C6C20636865636B20697473656C660D0A202020202020696620';
wwv_flow_api.g_varchar2_table(109) := '28212428704576656E742E746172676574292E69732873656C662E686561646572436865636B626F78242929207B0D0A202020202020202073656C662E686561646572436865636B626F78242E70726F702827636865636B6564272C202173656C662E68';
wwv_flow_api.g_varchar2_table(110) := '6561646572436865636B626F78242E70726F702827636865636B65642729293B0D0A2020202020207D0D0A2020202020206966202873656C662E686561646572436865636B626F78242E70726F702827636865636B65642729297B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(111) := '202F2F2073656C65637420616C6C2076697369626C650D0A202020202020202073656C662E63656C6C43686563626F786573242E656163682866756E6374696F6E28297B0D0A202020202020202020206C6574200D0A2020202020202020202020206368';
wwv_flow_api.g_varchar2_table(112) := '6563626F7824203D20242874686973292C0D0A20202020202020202020202076616C7565202020203D2063686563626F78242E76616C28293B0D0A2020202020202020202073656C662E5F616464546F53656C656374656456616C7565732876616C7565';
wwv_flow_api.g_varchar2_table(113) := '293B0D0A20202020202020207D293B0D0A2020202020207D20656C7365207B0D0A20202020202020202F2F20636C65617220616C6C2076697369626C650D0A202020202020202073656C662E63656C6C43686563626F786573242E656163682866756E63';
wwv_flow_api.g_varchar2_table(114) := '74696F6E28297B0D0A202020202020202020206C6574200D0A20202020202020202020202063686563626F7824203D20242874686973292C0D0A20202020202020202020202076616C7565202020203D2063686563626F78242E76616C28293B0D0A2020';
wwv_flow_api.g_varchar2_table(115) := '202020202020202073656C662E5F72656D6F766546726F6D53656C656374656456616C7565732876616C7565293B0D0A20202020202020207D293B0D0A2020202020207D0D0A20202020202073656C662E5F6170706C7953656C656374696F6E28293B20';
wwv_flow_api.g_varchar2_table(116) := '0D0A20202020202073656C662E5F73746F726556616C75657328293B0D0A2020202020200D0A202020207D2C0D0A0D0A202020205F6170706C7953656C656374696F6E3A2066756E6374696F6E28297B0D0A2020202020207661722073656C66203D2074';
wwv_flow_api.g_varchar2_table(117) := '6869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C20274170706C79696E672076697375616C207374796C6520746F2073656C656374656420726F';
wwv_flow_api.g_varchar2_table(118) := '77732E2E2E27293B20202020200D0A0D0A2020202020202F2F20636C65617220616C6C206362780D0A2020202020202F2F2072656D6F76652073656C656374656420726F77207374796C65730D0A20202020202073656C662E63656C6C43686563626F78';
wwv_flow_api.g_varchar2_table(119) := '6573242E70726F702827636865636B6564272C2066616C7365293B0D0A20202020202073656C662E686561646572436865636B626F78242E70726F702827636865636B6564272C2066616C7365293B0D0A20202020202073656C662E63656C6C43686563';
wwv_flow_api.g_varchar2_table(120) := '626F786573242E636C6F736573742827747227292E72656D6F7665436C6173732873656C662E435F53454C45435445445F524F575F434C415353293B0D0A0D0A2020202020202F2F2073656C65637420636865636B626F786573206163636F7264696E67';
wwv_flow_api.g_varchar2_table(121) := '20746F2073656C65637465642076616C7565732061727261790D0A2020202020202F2F20616464207374796C6520746F2073656C656374656420726F77730D0A20202020202073656C662E63656C6C43686563626F786573242E656163682866756E6374';
wwv_flow_api.g_varchar2_table(122) := '696F6E28297B0D0A20202020202020206C6574200D0A20202020202020202020636865636B626F7824203D20242874686973292C0D0A2020202020202020202076616C756520202020203D20636865636B626F78242E76616C28292C0D0A202020202020';
wwv_flow_api.g_varchar2_table(123) := '20202020726F77242020202020203D20636865636B626F78242E636C6F736573742827747227293B0D0A20202020202020206966202873656C662E73656C656374656456616C7565732E696E636C756465732876616C756529297B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(124) := '202020636865636B626F78242E70726F702827636865636B6564272C2074727565293B0D0A20202020202020202020726F77242E616464436C6173732873656C662E435F53454C45435445445F524F575F434C415353293B0D0A20202020202020207D20';
wwv_flow_api.g_varchar2_table(125) := '0D0A2020202020207D293B0D0A0D0A2020202020202F2F20636865636B2069662068656164657220636865636B626F782073686F756C6420626520636865636B65640D0A2020202020206966202873656C662E63656C6C43686563626F786573242E6C65';
wwv_flow_api.g_varchar2_table(126) := '6E677468203D3D3D2073656C662E63656C6C43686563626F786573242E66696C74657228223A636865636B656422292E6C656E677468297B0D0A202020202020202073656C662E686561646572436865636B626F78242E70726F702827636865636B6564';
wwv_flow_api.g_varchar2_table(127) := '272C2074727565293B0D0A2020202020207D0D0A202020207D2C20200D0A2020200D0A202020205F616464546F53656C656374656456616C7565733A2066756E6374696F6E287056616C7565297B0D0A2020202020207661722073656C66203D20746869';
wwv_flow_api.g_varchar2_table(128) := '733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027416464696E672076616C756520746F2063757272656E746C792073656C6563746564';
wwv_flow_api.g_varchar2_table(129) := '20726F77733A20272C207056616C7565293B0D0A2020202020200D0A202020202020696620282173656C662E73656C656374656456616C7565732E696E636C75646573287056616C756529297B0D0A202020202020202073656C662E73656C6563746564';
wwv_flow_api.g_varchar2_table(130) := '56616C7565732E70757368287056616C7565293B0D0A2020202020207D2020202020200D0A202020207D2C0D0A202020205F72656D6F766546726F6D53656C656374656456616C7565733A2066756E6374696F6E287056616C7565297B0D0A2020202020';
wwv_flow_api.g_varchar2_table(131) := '207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202752656D6F76696E672076616C75652066726F6D';
wwv_flow_api.g_varchar2_table(132) := '2063757272656E746C792073656C656374656420726F77733A20272C207056616C7565293B0D0A0D0A20202020202073656C662E73656C656374656456616C7565732E73706C6963652873656C662E73656C656374656456616C7565732E696E6465784F';
wwv_flow_api.g_varchar2_table(133) := '66287056616C7565292C2031293B0D0A202020207D2C20202020202020200D0A202020205F636C65617253656C656374656456616C7565733A2066756E6374696F6E28297B0D0A2020202020207661722073656C66203D20746869733B0D0A2020202020';
wwv_flow_api.g_varchar2_table(134) := '2064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027436C656172696E672073656C65637465642076616C7565732E2E2E27293B0D0A0D0A20202020202073656C';
wwv_flow_api.g_varchar2_table(135) := '662E73656C656374656456616C756573203D205B5D3B20202020202020202020200D0A202020207D2C202020200D0A0D0A202020205F67657453746F72656456616C7565733A2066756E6374696F6E28297B0D0A2020202020207661722073656C66203D';
wwv_flow_api.g_varchar2_table(136) := '20746869733B0D0A20202020202073656C662E73656C656374656456616C756573203D20205B5D3B202F2F20696E697469616C697A6520656D7074792061727261790D0A2020202020200D0A2020202020202F2F2069662073656C656374696F6E206973';
wwv_flow_api.g_varchar2_table(137) := '2073746F72656420696E20636F6C6C656374696F6E207468656E2074727920746F20726561642069740D0A2020202020206966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F';
wwv_flow_api.g_varchar2_table(138) := '6E297B0D0A202020202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D20';
wwv_flow_api.g_varchar2_table(139) := '4150455820636F6C6C656374696F6E2E2E2E27293B0D0A20202020202020206C65740D0A20202020202020202020616A617844617461203D207B0D0A20202020202020202020202022783031223A2022474554222C0D0A20202020202020202020202022';
wwv_flow_api.g_varchar2_table(140) := '783033223A2073656C662E73746F7261676550726F706572746965732E73746F72616765436F6C6C656374696F6E4E616D650D0A202020202020202020207D2C0D0A20202020202020202020616A61784F7074696F6E73203D207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(141) := '20202020202273756363657373222020202020202020202020202020202020203A20242E70726F78792873656C662E5F67657453746F72656456616C756573416A6178737563636573732C2020202073656C66292C0D0A20202020202020202020202022';
wwv_flow_api.g_varchar2_table(142) := '6572726F722220202020202020202020202020202020202020203A20242E70726F78792873656C662E5F67657453746F72656456616C756573416A61786572726F722C20202020202073656C66292C0D0A20202020202020202020202022746172676574';
wwv_flow_api.g_varchar2_table(143) := '22202020202020202020202020202020202020203A202723272B73656C662E7265706F727450726F706572746965732E726567696F6E49642C0D0A202020202020202020202020226C6F6164696E67496E64696361746F72222020202020202020203A20';
wwv_flow_api.g_varchar2_table(144) := '2723272B73656C662E7265706F727450726F706572746965732E726567696F6E49642C0D0A202020202020202020202020226C6F6164696E67496E64696361746F72506F736974696F6E22203A202263656E7465726564220D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(145) := '7D3B200D0A202020202020202020200D0A2020202020202020617065782E7365727665722E706C7567696E20282073656C662E6F7074696F6E732E616A61784964656E7469666965722C20616A6178446174612C20616A61784F7074696F6E7320293B0D';
wwv_flow_api.g_varchar2_table(146) := '0A202020202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D2041504558';
wwv_flow_api.g_varchar2_table(147) := '20636F6C6C656374696F6E2E2E2E272C2027416A61782073656E7427293B20200D0A2020202020207D0D0A2020202020202F2F2069662073656C656374696F6E206973206E6F742073746F72656420696E20636F6C6C656374696F6E2C20627574206973';
wwv_flow_api.g_varchar2_table(148) := '2073746F72656420696E2061706578206974656D207468656E20726561642069740D0A2020202020202F2F20616E64206170706C7920746F207265706F72740D0A202020202020656C7365206966202873656C662E73746F7261676550726F7065727469';
wwv_flow_api.g_varchar2_table(149) := '65732E73746F726553656C6563746564496E4974656D2026262024762873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D652920213D202222297B0D0A202020202020202064656275672E6D65737361676528';
wwv_flow_api.g_varchar2_table(150) := '73656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D2041504558204974656D2E2E2E27293B0D0A20202020202020207365';
wwv_flow_api.g_varchar2_table(151) := '6C662E73656C656374656456616C756573203D2024762873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D65292E73706C69742873656C662E73746F7261676550726F706572746965732E76616C7565536570';
wwv_flow_api.g_varchar2_table(152) := '617261746F72293B0D0A202020202020202073656C662E5F6170706C7953656C656374696F6E28293B0D0A2020202020207D200D0A202020207D2C0D0A202020205F67657453746F72656456616C756573416A6178737563636573733A2066756E637469';
wwv_flow_api.g_varchar2_table(153) := '6F6E2870446174612C2070546578745374617475732C20704A71584852297B0D0A2020202020207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073';
wwv_flow_api.g_varchar2_table(154) := '656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820636F6C6C656374696F6E2E2E2E272C2027416A61782073756363657373272C2070446174612C20705465787453';
wwv_flow_api.g_varchar2_table(155) := '74617475732C20704A71584852293B0D0A0D0A20202020202073656C662E73656C656374656456616C756573203D2070446174612E73656C656374656456616C7565732E6D6170286F626A203D3E206F626A2E636865636B626F785F76616C7565293B0D';
wwv_flow_api.g_varchar2_table(156) := '0A20202020202073656C662E5F6170706C7953656C656374696F6E28293B0D0A202020207D2C0D0A202020205F67657453746F72656456616C756573416A61786572726F723A2066756E6374696F6E28704A715848522C2070546578745374617475732C';
wwv_flow_api.g_varchar2_table(157) := '20704572726F725468726F776E297B0D0A2020202020207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F505245464958';
wwv_flow_api.g_varchar2_table(158) := '2C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820636F6C6C656374696F6E2E2E2E272C2027416A6178206572726F72272C20704A715848522C2070546578745374617475732C20704572726F725468726F';
wwv_flow_api.g_varchar2_table(159) := '776E20293B0D0A0D0A2020202020202F2F2069662076616C75652063616E206265206F627461696E65642066726F6D2061706578206974656D207468656E2074727920746F20646F2069740D0A2020202020206966202873656C662E73746F7261676550';
wwv_flow_api.g_varchar2_table(160) := '726F706572746965732E73746F726553656C6563746564496E4974656D20297B0D0A202020202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20275265';
wwv_flow_api.g_varchar2_table(161) := '73746F72696E672073656C65637465642076616C7565732066726F6D2041504558204974656D2E2E2E27293B0D0A202020202020202073656C662E73656C656374656456616C756573203D2024762873656C662E73746F7261676550726F706572746965';
wwv_flow_api.g_varchar2_table(162) := '732E73746F726167654974656D4E616D65292E73706C69742873656C662E73746F7261676550726F706572746965732E76616C7565536570617261746F72293B0D0A202020202020202073656C662E5F6170706C7953656C656374696F6E28293B0D0A20';
wwv_flow_api.g_varchar2_table(163) := '20202020207D200D0A20202020202073656C662E5F7468726F774572726F7228275F67657453746F72656456616C756573416A61786572726F72272C2073656C662E435F4552524F525F414A41585F524541445F4641494C5552452C2066616C7365293B';
wwv_flow_api.g_varchar2_table(164) := '0D0A202020207D2C0D0A0D0A20200D0A202020205F73746F726556616C7565733A2066756E6374696F6E28297B0D0A2020202020207661722073656C66203D20746869733B0D0A0D0A2020202020202F2F2073746F72696E672073656C65637465642076';
wwv_flow_api.g_varchar2_table(165) := '616C75657320696E2061706578206974656D200D0A2020202020206966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D297B202020200D0A202020202020202064656275672E6D65737361';
wwv_flow_api.g_varchar2_table(166) := '67652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202753746F72696E672073656C65637465642076616C75657320696E2041504558206974656D2E2E2E27293B0D0A20202020202020202F2F2069662073';
wwv_flow_api.g_varchar2_table(167) := '656C656374696F6E2063616E6E6F7420657863656564206D6178696D756D206C656E67746820696E206279746573207468656E0D0A20202020202020202F2F2072656D6F7665206C6173742073656C65637465642076616C75657320756E74696C6C2069';
wwv_flow_api.g_varchar2_table(168) := '7420666974730D0A20202020202020206966202873656C662E73746F7261676550726F706572746965732E6C696D697453656C656374696F6E203D3D3D2027592720297B0D0A202020202020202020206C6574200D0A202020202020202020202020656E';
wwv_flow_api.g_varchar2_table(169) := '636F646572203D206E65772054657874456E636F64657228292C0D0A20202020202020202020202073656C656374696F6E45786365646564203D2066616C73653B0D0A202020202020202020207768696C65202820656E636F6465722E656E636F646528';
wwv_flow_api.g_varchar2_table(170) := '2073656C662E73656C656374656456616C7565732E6A6F696E2873656C662E73746F7261676550726F706572746965732E76616C7565536570617261746F722920292E6C656E677468203E2073656C662E435F53544F524147455F4954454D5F4D41585F';
wwv_flow_api.g_varchar2_table(171) := '42595445535F434F554E5420297B0D0A20202020202020202020202073656C662E73656C656374656456616C7565732E706F7028293B0D0A20202020202020202020202073656C656374696F6E45786365646564203D20747275653B0D0A202020202020';
wwv_flow_api.g_varchar2_table(172) := '202020207D0D0A202020202020202020206966202873656C656374696F6E45786365646564297B0D0A20202020202020202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F50524546';
wwv_flow_api.g_varchar2_table(173) := '49582C20274C696D6974696E672073656C656374696F6E206C656E67746820746F206D6178696D756D206E756D626572206F6620627974657320272C2073656C662E435F53544F524147455F4954454D5F4D41585F42595445535F434F554E54293B0D0A';
wwv_flow_api.g_varchar2_table(174) := '202020202020202020202020617065782E6576656E742E747269676765722873656C662E726567696F6E242C2073656C662E435F4556454E545F4D41585F53454C454354494F4E5F45584345444544293B0D0A20202020202020202020202073656C662E';
wwv_flow_api.g_varchar2_table(175) := '5F6170706C7953656C656374696F6E28293B0D0A202020202020202020207D202020202020202020200D0A2020202020202020202024732873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D652C2073656C66';
wwv_flow_api.g_varchar2_table(176) := '2E73656C656374656456616C7565732E6A6F696E2873656C662E73746F7261676550726F706572746965732E76616C7565536570617261746F722920293B0D0A2020202020202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C';
wwv_flow_api.g_varchar2_table(177) := '564C5F362C2073656C662E435F4C4F475F5052454649582C202753656C65637465642076616C7565732073746F72656420696E2041504558206974656D207375636365737366756C6C7927293B0D0A20202020202020207D200D0A20202020202020200D';
wwv_flow_api.g_varchar2_table(178) := '0A20202020202020202F2F2069662073656C6C656374696F6E206973206E6F74206C696D69746564207468656E20777269746520697420746F207468652061706578206974656D0D0A2020202020202020656C7365207B0D0A2020202020202020202024';
wwv_flow_api.g_varchar2_table(179) := '732873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D652C2073656C662E73656C656374656456616C7565732E6A6F696E2873656C662E73746F7261676550726F706572746965732E76616C75655365706172';
wwv_flow_api.g_varchar2_table(180) := '61746F722920293B0D0A2020202020202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202753656C65637465642076616C7565732073746F72656420696E204150';
wwv_flow_api.g_varchar2_table(181) := '4558206974656D207375636365737366756C6C7927293B0D0A20202020202020207D20202020202020200D0A2020202020207D0D0A0D0A2020202020202F2F2073746F72696E672073656C65637465642076616C75657320696E206170657820636F6C6C';
wwv_flow_api.g_varchar2_table(182) := '656374696F6E0D0A2020202020206966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E207C7C2073656C662E73746F7261676550726F706572746965732E6974656D417574';
wwv_flow_api.g_varchar2_table(183) := '6F5375626D6974297B0D0A202020202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027536176696E672073656C65637465642076616C75657320746F';
wwv_flow_api.g_varchar2_table(184) := '20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E2E2E27293B0D0A20202020202020206C65740D0A20202020202020202020616A617844617461203D207B0D0A20202020202020202020202022783031223A';
wwv_flow_api.g_varchar2_table(185) := '2073656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E203F202253455422203A20225355424D4954222C0D0A20202020202020202020202022783032223A2073656C662E73746F7261';
wwv_flow_api.g_varchar2_table(186) := '676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E2C0D0A20202020202020202020202022783033223A2073656C662E73746F7261676550726F706572746965732E73746F72616765436F6C6C656374696F6E';
wwv_flow_api.g_varchar2_table(187) := '4E616D652C0D0A20202020202020202020202022663031223A2073656C662E73656C656374656456616C7565730D0A202020202020202020207D2C0D0A20202020202020202020616A61784F7074696F6E73203D207B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(188) := '227375636365737322202020203A20242E70726F78792873656C662E5F73746F726556616C756573416A6178737563636573732C2020202073656C66292C0D0A202020202020202020202020226572726F72222020202020203A20242E70726F78792873';
wwv_flow_api.g_varchar2_table(189) := '656C662E5F73746F726556616C756573416A61786572726F722C20202020202073656C66290D0A202020202020202020207D3B200D0A20202020202020206966202873656C662E73746F7261676550726F706572746965732E6974656D4175746F537562';
wwv_flow_api.g_varchar2_table(190) := '6D6974297B0D0A20202020202020202020616A6178446174612E706167654974656D73203D205B73656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D655D3B0D0A20202020202020207D0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(191) := '617065782E7365727665722E706C7567696E20282073656C662E6F7074696F6E732E616A61784964656E7469666965722C20616A6178446174612C20616A61784F7074696F6E7320293B0D0A202020202020202064656275672E6D657373616765287365';
wwv_flow_api.g_varchar2_table(192) := '6C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027536176696E672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F';
wwv_flow_api.g_varchar2_table(193) := '6E292E2E2E272C2027416A61782073656E7427293B200D0A2020202020207D0D0A202020207D2C202020200D0A0D0A202020205F73746F726556616C756573416A6178737563636573733A2066756E6374696F6E2870446174612C207054657874537461';
wwv_flow_api.g_varchar2_table(194) := '7475732C20704A71584852297B0D0A2020202020207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20';
wwv_flow_api.g_varchar2_table(195) := '27536176696E672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E2E2E272C2027416A61782073756363657373272C2070446174612C207054657874537461';
wwv_flow_api.g_varchar2_table(196) := '7475732C20704A71584852293B0D0A202020207D2C0D0A202020205F73746F726556616C756573416A61786572726F723A2066756E6374696F6E28704A715848522C2070546578745374617475732C20704572726F725468726F776E297B0D0A20202020';
wwv_flow_api.g_varchar2_table(197) := '20207661722073656C66203D20746869733B0D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027536176696E672073656C6563746564207661';
wwv_flow_api.g_varchar2_table(198) := '6C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E2E2E272C2027416A6178206572726F72272C20704A715848522C2070546578745374617475732C20704572726F725468726F776E20293B';
wwv_flow_api.g_varchar2_table(199) := '0D0A0D0A20202020202073656C662E5F7468726F774572726F7228275F73746F726556616C756573416A61786572726F72272C2073656C662E435F4552524F525F414A41585F53544F52455F4641494C5552452C2066616C7365293B0D0A202020207D2C';
wwv_flow_api.g_varchar2_table(200) := '0D0A0D0A202020205F7468726F774572726F723A2066756E6374696F6E287046756E6374696F6E4E616D652C20704572726F724D6573736167652C207053746F70506C7567696E2C2070446973706C6179506167654572726F724D65737361676573297B';
wwv_flow_api.g_varchar2_table(201) := '0D0A202020202020766172200D0A202020202020202073656C66203D20746869732C0D0A2020202020202020646973706C6179506167654572726F724D65737361676573203D2070446973706C6179506167654572726F724D65737361676573207C7C20';
wwv_flow_api.g_varchar2_table(202) := '73656C662E435F444953504C41595F504147455F4552524F525F4D455353414745532C0D0A2020202020202020656E64557365724572726F724D657373616765203D2073656C662E435F454E445F555345525F4552524F525F505245464958202B207045';
wwv_flow_api.g_varchar2_table(203) := '72726F724D657373616765202B2073656C662E435F454E445F555345525F4552524F525F5355464649583B0D0A2020202020200D0A20202020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F4552524F522C2073656C662E';
wwv_flow_api.g_varchar2_table(204) := '435F4C4F475F5052454649582C207046756E6374696F6E4E616D652C20704572726F724D657373616765293B0D0A2020202020200D0A20202020202069662028646973706C6179506167654572726F724D65737361676573297B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(205) := '617065782E6D6573736167652E636C6561724572726F727328293B0D0A2020202020202020617065782E6D6573736167652E73686F774572726F7273287B0D0A20202020202020202020747970653A20202020202020226572726F72222C0D0A20202020';
wwv_flow_api.g_varchar2_table(206) := '2020202020206C6F636174696F6E3A2020202270616765222C0D0A202020202020202020206D6573736167653A20202020656E64557365724572726F724D6573736167652C0D0A20202020202020202020756E736166653A202020202066616C73650D0A';
wwv_flow_api.g_varchar2_table(207) := '20202020202020207D293B0D0A2020202020207D0D0A202020202020696620287053746F70506C7567696E297B0D0A20202020202020207468726F77206E6577204572726F7228656E64557365724572726F724D657373616765293B0D0A202020202020';
wwv_flow_api.g_varchar2_table(208) := '7D0D0A202020207D2C0D0A0D0A20202F2F206A517565727920776964676574207075626C6963206D6574686F6473200D0A0D0A2020636C65617253656C656374696F6E3A2066756E6374696F6E28297B0D0A202020207661722073656C66203D20746869';
wwv_flow_api.g_varchar2_table(209) := '733B0D0A2020202064656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027436C6561722073656C656374696F6E207075626C6963206D6574686F6420696E766F6B65';
wwv_flow_api.g_varchar2_table(210) := '642E2E2E27293B200D0A202020200D0A2020202073656C662E5F636C65617253656C656374656456616C75657328293B0D0A2020202073656C662E5F6170706C7953656C656374696F6E28293B0D0A2020202073656C662E5F73746F726556616C756573';
wwv_flow_api.g_varchar2_table(211) := '28293B0D0A20207D2C0D0A20202F2F206A517565727920776964676574206E6174697665206D6574686F64730D0A20205F64657374726F793A2066756E6374696F6E28297B0D0A20207D2C0D0A0D0A20202F2F206F7074696F6E733A2066756E6374696F';
wwv_flow_api.g_varchar2_table(212) := '6E2820704F7074696F6E7320297B0D0A20202F2F202020746869732E5F73757065722820704F7074696F6E7320293B0D0A20202F2F207D2C0D0A20205F7365744F7074696F6E3A2066756E6374696F6E2820704B65792C207056616C75652029207B0D0A';
wwv_flow_api.g_varchar2_table(213) := '202020206966202820704B6579203D3D3D202276616C7565222029207B0D0A2020202020207056616C7565203D20746869732E5F636F6E73747261696E28207056616C756520293B0D0A202020207D0D0A20202020746869732E5F73757065722820704B';
wwv_flow_api.g_varchar2_table(214) := '65792C207056616C756520293B0D0A20207D2C20200D0A20205F7365744F7074696F6E733A2066756E6374696F6E2820704F7074696F6E732029207B0D0A20202020746869732E5F73757065722820704F7074696F6E7320293B0D0A20207D2C20202020';
wwv_flow_api.g_varchar2_table(215) := '0D0A20200D0A20207D293B0D0A207D2928617065782E64656275672C20617065782E6A517565727920293B0D0A0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(7852877982377177)
,p_plugin_id=>wwv_flow_api.id(11790640840733610)
,p_file_name=>'smartCheckboxColumn.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
