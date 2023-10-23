FUNCTION f_render(
	p_dynamic_action in apex_plugin.t_dynamic_action,
	p_plugin         in apex_plugin.t_plugin 
) return apex_plugin.t_dynamic_action_render_result
IS 
	C_ATTR_SELECTION_SETTINGS     CONSTANT p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;
	C_ATTR_COLUMN_NAME            CONSTANT p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;
	C_ATTR_STORAGE_ITEM           CONSTANT p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;
	C_ATTR_STORAGE_COLLECTION     CONSTANT p_dynamic_action.attribute_04%type := NVL(p_dynamic_action.attribute_04, 'P'||V('APP_PAGE_ID')||'_SELECTED_VALUES');
	C_ATTR_VALUE_SEPARATOR        CONSTANT p_dynamic_action.attribute_05%type := NVL(p_dynamic_action.attribute_05, ':');
	C_ATTR_SELECTION_COLOR        CONSTANT p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;    
	C_ATTR_LIMIT_SELECTION        CONSTANT p_dynamic_action.attribute_07%type := NVL(p_dynamic_action.attribute_07, 'Y');
	C_ATTR_AUTO_SUBMIT_ITEM       CONSTANT p_dynamic_action.attribute_08%type := NVL(p_dynamic_action.attribute_08, 'N');  
	C_ATTR_EMPTY_CHECKBOX_ICON    CONSTANT p_dynamic_action.attribute_09%type := NVL(p_dynamic_action.attribute_09, 'fa-square-o');  
	C_ATTR_SELECTED_CHECKBOX_ICON CONSTANT p_dynamic_action.attribute_10%type := NVL(p_dynamic_action.attribute_10, 'fa-check-square-o');  
	C_ATTR_COLLECTION_COLUMNS     CONSTANT p_dynamic_action.attribute_11%type := p_dynamic_action.attribute_11;
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
				let 
					pluginInstanceId = '''||v_region_static_id||'_'||v_column_id||'_pscc'';
				$(''<div id="''+pluginInstanceId+''"></div>'').appendTo(''body'');
				$(''#''+pluginInstanceId).smartCheckboxColumn( {'																	||
						apex_javascript.add_attribute('ajaxIdentifier',				v_result.ajax_identifier)						||       
						apex_javascript.add_attribute('selectionSettings',			C_ATTR_SELECTION_SETTINGS)						||
						apex_javascript.add_attribute('columnName',					APEX_ESCAPE.HTML(C_ATTR_COLUMN_NAME) )			||
						apex_javascript.add_attribute('storageItemName',			C_ATTR_STORAGE_ITEM)							||
						apex_javascript.add_attribute('storageCollectionName',		APEX_ESCAPE.HTML(C_ATTR_STORAGE_COLLECTION) )	||
						apex_javascript.add_attribute('valueSeparator',				APEX_ESCAPE.HTML(C_ATTR_VALUE_SEPARATOR) )		||
						apex_javascript.add_attribute('selectionColor',				C_ATTR_SELECTION_COLOR)							||
						apex_javascript.add_attribute('limitSelection',				C_ATTR_LIMIT_SELECTION)							||
						apex_javascript.add_attribute('itemAutoSubmit',				C_ATTR_AUTO_SUBMIT_ITEM)						||    
						apex_javascript.add_attribute('emptyCheckboxIcon',			C_ATTR_EMPTY_CHECKBOX_ICON)						||   
						apex_javascript.add_attribute('selectedCheckboxIcon',		C_ATTR_SELECTED_CHECKBOX_ICON)					||   
						apex_javascript.add_attribute('additionalCollectionColumns',		C_ATTR_COLLECTION_COLUMNS)					||   
						
						apex_javascript.add_attribute('regionId',					v_region_static_id)								||          
						apex_javascript.add_attribute('regionTemplate',				v_region_template)								||
						apex_javascript.add_attribute('reportType',					v_report_type )									||
						apex_javascript.add_attribute('reportTemplate',				v_report_template )								||  
						apex_javascript.add_attribute('columnId',					v_column_id, false, false )						||          
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
	v_extra_values     APEX_APPLICATION_GLOBAL.VC_ARR2 DEFAULT APEX_APPLICATION.G_F02;
	
	type t_extraValues is table of APEX_APPLICATION_GLOBAL.VC_ARR2;
	tr_extraValues t_extraValues := t_extraValues();
	type t_varchars is table of varchar2(4000) index by PLS_INTEGER;
	tr_varchars t_varchars;

	v_ajax_command     varchar2(30)  DEFAULT APEX_APPLICATION.G_X01;
	v_save_to_coll     varchar2(30)  DEFAULT APEX_APPLICATION.G_X02;
	v_collection_name  varchar2(255) DEFAULT upper(APEX_APPLICATION.G_X03);
	v_collection_query varchar2(4000);
	v_ref_cur          sys_refcursor;
	v_result           apex_plugin.t_dynamic_action_ajax_result;
	v_array_count number;
BEGIN
	--debug
	IF apex_application.g_debug THEN
		apex_plugin_util.debug_dynamic_action (
			p_plugin         => p_plugin,
			p_dynamic_action => p_dynamic_action
		);
	END IF;
    
	for extVal in (select COLUMN_VALUE, ROWNUM from table(v_extra_values)) loop --inifni
		for val in (select replace(COLUMN_VALUE, 'undefined', null) as COLUMN_VALUE, ROWNUM from table(apex_string.split(v_extra_values(extVal.ROWNUM), ':')) ) -- 3
		loop
			begin
				tr_varchars(val.ROWNUM) := tr_varchars(val.ROWNUM) || ':' || val.COLUMN_VALUE;
			exception
				when no_data_found then
					tr_varchars(val.ROWNUM) := val.COLUMN_VALUE;
			end;
			tr_extraValues.extend;
			tr_extraValues(val.ROWNUM) := apex_util.STRING_TO_TABLE(tr_varchars(val.ROWNUM), ':');
		end loop;
	end loop;

	CASE upper(v_ajax_command)
		WHEN 'GET' THEN
			open v_ref_cur for
				SELECT
					C001 as "checkbox_value",
					nvl(C002, 'undefined') || ':' ||
					nvl(c003, 'undefined') || ':' ||
					nvl(c004, 'undefined') || ':' ||
					nvl(c005, 'undefined') || ':' ||
					nvl(c006, 'undefined') || ':' ||
					nvl(c007, 'undefined') || ':' ||
					nvl(c008, 'undefined') || ':' ||
					nvl(c009, 'undefined') || ':' ||
					nvl(c010, 'undefined') || ':' ||
					nvl(c011, 'undefined') || ':' ||
					nvl(c012, 'undefined') || ':' ||
					nvl(c013, 'undefined') || ':' ||
					nvl(c014, 'undefined') || ':' ||
					nvl(c015, 'undefined') || ':' ||
					nvl(c016, 'undefined') || ':' ||
					nvl(c017, 'undefined') || ':' ||
					nvl(c018, 'undefined') || ':' ||
					nvl(c019, 'undefined') || ':' ||
					nvl(c020, 'undefined') || ':' ||
					nvl(c021, 'undefined') || ':' ||
					nvl(c022, 'undefined') || ':' ||
					nvl(c023, 'undefined') || ':' ||
					nvl(c024, 'undefined') || ':' ||
					nvl(c025, 'undefined') || ':' ||
					nvl(c026, 'undefined') || ':' ||
					nvl(c027, 'undefined') || ':' ||
					nvl(c028, 'undefined') || ':' ||
					nvl(c029, 'undefined') || ':' ||
					nvl(c030, 'undefined') || ':' ||
					nvl(c031, 'undefined') || ':' ||
					nvl(c032, 'undefined') || ':' ||
					nvl(c033, 'undefined') || ':' ||
					nvl(c034, 'undefined') || ':' ||
					nvl(c035, 'undefined') || ':' ||
					nvl(c036, 'undefined') || ':' ||
					nvl(c037, 'undefined') || ':' ||
					nvl(c038, 'undefined') || ':' ||
					nvl(c039, 'undefined') || ':' ||
					nvl(c040, 'undefined') || ':' ||
					nvl(c041, 'undefined') || ':' ||
					nvl(c042, 'undefined') || ':' ||
					nvl(c043, 'undefined') || ':' ||
					nvl(c044, 'undefined') || ':' ||
					nvl(c045, 'undefined') || ':' ||
					nvl(c046, 'undefined') || ':' ||
					nvl(c047, 'undefined') || ':' ||
					nvl(c048, 'undefined') || ':' ||
					nvl(c049, 'undefined') || ':' ||
					nvl(c050, 'undefined') as "extra_values"
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

        		v_array_count := tr_extraValues.COUNT;

				APEX_COLLECTION.ADD_MEMBERS(
					p_collection_name => v_collection_name,
					p_c001            => v_selected_values,
					p_c002 => case when v_array_count >= 1 then tr_extraValues(1) else null end,
					p_c003 => case when v_array_count >= 2 then tr_extraValues(2) else null end,
					p_c004 => case when v_array_count >= 3 then tr_extraValues(3) else null end,
					p_c005 => case when v_array_count >= 4 then tr_extraValues(4) else null end,
					p_c006 => case when v_array_count >= 5 then tr_extraValues(5) else null end,
					p_c007 => case when v_array_count >= 6 then tr_extraValues(6) else null end,
					p_c008 => case when v_array_count >= 7 then tr_extraValues(7) else null end,
					p_c009 => case when v_array_count >= 8 then tr_extraValues(8) else null end,
					p_c010 => case when v_array_count >= 9 then tr_extraValues(9) else null end,
					p_c011 => case when v_array_count >= 10 then tr_extraValues(10) else null end,
					p_c012 => case when v_array_count >= 11 then tr_extraValues(11) else null end,
					p_c013 => case when v_array_count >= 12 then tr_extraValues(12) else null end,
					p_c014 => case when v_array_count >= 13 then tr_extraValues(13) else null end,
					p_c015 => case when v_array_count >= 14 then tr_extraValues(14) else null end,
					p_c016 => case when v_array_count >= 15 then tr_extraValues(15) else null end,
					p_c017 => case when v_array_count >= 16 then tr_extraValues(16) else null end,
					p_c018 => case when v_array_count >= 17 then tr_extraValues(17) else null end,
					p_c019 => case when v_array_count >= 18 then tr_extraValues(18) else null end,
					p_c020 => case when v_array_count >= 19 then tr_extraValues(19) else null end,
					p_c021 => case when v_array_count >= 20 then tr_extraValues(20) else null end,
					p_c022 => case when v_array_count >= 21 then tr_extraValues(21) else null end,
					p_c023 => case when v_array_count >= 22 then tr_extraValues(22) else null end,
					p_c024 => case when v_array_count >= 23 then tr_extraValues(23) else null end,
					p_c025 => case when v_array_count >= 24 then tr_extraValues(24) else null end,
					p_c026 => case when v_array_count >= 25 then tr_extraValues(25) else null end,
					p_c027 => case when v_array_count >= 26 then tr_extraValues(26) else null end,
					p_c028 => case when v_array_count >= 27 then tr_extraValues(27) else null end,
					p_c029 => case when v_array_count >= 28 then tr_extraValues(28) else null end,
					p_c030 => case when v_array_count >= 29 then tr_extraValues(29) else null end,
					p_c031 => case when v_array_count >= 30 then tr_extraValues(30) else null end,
					p_c032 => case when v_array_count >= 31 then tr_extraValues(31) else null end,
					p_c033 => case when v_array_count >= 32 then tr_extraValues(32) else null end,
					p_c034 => case when v_array_count >= 33 then tr_extraValues(33) else null end,
					p_c035 => case when v_array_count >= 34 then tr_extraValues(34) else null end,
					p_c036 => case when v_array_count >= 35 then tr_extraValues(35) else null end,
					p_c037 => case when v_array_count >= 36 then tr_extraValues(36) else null end,
					p_c038 => case when v_array_count >= 37 then tr_extraValues(37) else null end,
					p_c039 => case when v_array_count >= 38 then tr_extraValues(38) else null end,
					p_c040 => case when v_array_count >= 39 then tr_extraValues(39) else null end,
					p_c041 => case when v_array_count >= 40 then tr_extraValues(40) else null end,
					p_c042 => case when v_array_count >= 41 then tr_extraValues(41) else null end,
					p_c043 => case when v_array_count >= 42 then tr_extraValues(42) else null end,
					p_c044 => case when v_array_count >= 43 then tr_extraValues(43) else null end,
					p_c045 => case when v_array_count >= 44 then tr_extraValues(44) else null end,
					p_c046 => case when v_array_count >= 45 then tr_extraValues(45) else null end,
					p_c047 => case when v_array_count >= 46 then tr_extraValues(46) else null end,
					p_c048 => case when v_array_count >= 47 then tr_extraValues(47) else null end,
					p_c049 => case when v_array_count >= 48 then tr_extraValues(48) else null end,
					p_c050 => case when v_array_count >= 49 then tr_extraValues(49) else null end
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
