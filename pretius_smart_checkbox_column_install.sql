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
,p_default_application_id=>108
,p_default_owner=>'SMART_CB'
);
end;
/
prompt --application/shared_components/plugins/dynamic_action/pretius_smart_checkbox_column
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(98201821780201218)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'PRETIUS_SMART_CHECKBOX_COLUMN'
,p_display_name=>'Pretius Smart Checkbox Column'
,p_category=>'INIT'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'FUNCTION f_render(',
'	p_dynamic_action in apex_plugin.t_dynamic_action,',
'	p_plugin         in apex_plugin.t_plugin ',
') return apex_plugin.t_dynamic_action_render_result',
'IS ',
'	C_ATTR_SELECTION_SETTINGS     CONSTANT p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'	C_ATTR_COLUMN_NAME            CONSTANT p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'	C_ATTR_STORAGE_ITEM           CONSTANT p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'	C_ATTR_STORAGE_COLLECTION     CONSTANT p_dynamic_action.attribute_04%type := NVL(p_dynamic_action.attribute_04, ''P''||V(''APP_PAGE_ID'')||''_SELECTED_VALUES'');',
'	C_ATTR_VALUE_SEPARATOR        CONSTANT p_dynamic_action.attribute_05%type := NVL(p_dynamic_action.attribute_05, '':'');',
'	C_ATTR_SELECTION_COLOR        CONSTANT p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;    ',
'	C_ATTR_LIMIT_SELECTION        CONSTANT p_dynamic_action.attribute_07%type := NVL(p_dynamic_action.attribute_07, ''Y'');',
'	C_ATTR_AUTO_SUBMIT_ITEM       CONSTANT p_dynamic_action.attribute_08%type := NVL(p_dynamic_action.attribute_08, ''N'');  ',
'	C_ATTR_EMPTY_CHECKBOX_ICON    CONSTANT p_dynamic_action.attribute_09%type := NVL(p_dynamic_action.attribute_09, ''fa-square-o'');  ',
'	C_ATTR_SELECTED_CHECKBOX_ICON CONSTANT p_dynamic_action.attribute_10%type := NVL(p_dynamic_action.attribute_10, ''fa-check-square-o'');  ',
'	C_ATTR_COLLECTION_COLUMNS     CONSTANT p_dynamic_action.attribute_11%type := p_dynamic_action.attribute_11;',
'	v_result                   apex_plugin.t_dynamic_action_render_result;',
'	',
'	v_dynamic_action_id        varchar2(100);',
'	v_region_id                varchar2(100);',
'	v_region_static_id         varchar2(100);',
'	v_region_template          varchar2(100);',
'	v_report_type              varchar2(100);',
'	v_report_template          varchar2(100);',
'	v_column_id                varchar2(100);',
'	v_css                      varchar2(4000);',
'	v_error                    varchar2(4000);',
'',
'BEGIN',
'	IF apex_application.g_debug THEN',
'		apex_plugin_util.debug_dynamic_action (',
'			p_plugin         => p_plugin,',
'			p_dynamic_action => p_dynamic_action ',
'		);',
'	END IF;',
'	',
'	-- get region id associated with action',
'	BEGIN',
'		SELECT ',
'			AFFECTED_REGION_ID',
'		INTO',
'			v_region_id',
'		FROM ',
'			APEX_APPLICATION_PAGE_DA_ACTS ',
'		WHERE   ',
'			ACTION_ID = p_dynamic_action.id;',
'	EXCEPTION ',
'		WHEN NO_DATA_FOUND THEN ',
'			v_error := ''Pretius Smart Checkbox Column: Could not find affected report region. Contact application administrator.'';',
'		WHEN TOO_MANY_ROWS THEN ',
'			v_error := ''Pretius Smart Checkbox Column: More than one affected report regions found. Contact application administrator.'';',
'	END;',
'',
'	-- get region/report inforamtions',
'	BEGIN',
'		SELECT ',
'			NVL(STATIC_ID, ''R''||REGION_ID) REGION_STATIC_ID,',
'			TEMPLATE, ',
'			CASE  SOURCE_TYPE',
'				WHEN ''Report'' THEN ''Classic Report''',
'				ELSE SOURCE_TYPE',
'				END SOURCE_TYPE,',
'			REPORT_TEMPLATE ',
'		INTO ',
'			v_region_static_id,',
'			v_region_template,',
'			v_report_type,',
'			v_report_template',
'		FROM ',
'			APEX_APPLICATION_PAGE_REGIONS',
'		WHERE ',
'			REGION_ID = v_region_id;',
'	EXCEPTION ',
'		WHEN NO_DATA_FOUND THEN ',
'			v_error := ''Pretius Smart Checkbox Column: Could not read report region details. Contact application administrator.'';',
'		WHEN TOO_MANY_ROWS THEN ',
'			v_error := ''Pretius Smart Checkbox Column: Report region details ambiguously defined. Contact application administrator.'';',
'	END;',
'',
'	/* v_report_type - Report types:',
'	Report',
'	Interactive Report',
'	Interactive Grid',
'	Reflow Report',
'	Column Toggle Report',
'	*/',
'	BEGIN',
'		CASE v_report_type',
'			WHEN ''Classic Report'' THEN',
'				-- Classic report',
'				SELECT ',
'					NVL(STATIC_ID, COLUMN_ALIAS)',
'				INTO',
'					v_column_id',
'				FROM ',
'					APEX_APPLICATION_PAGE_RPT_COLS',
'				WHERE ',
'					REGION_ID = v_region_id',
'					AND COLUMN_ALIAS = C_ATTR_COLUMN_NAME;      ',
'			WHEN ''Interactive Report'' THEN',
'				-- Interactive report',
'				SELECT ',
'					 NVL(STATIC_ID, ''C''||COLUMN_ID)',
'				INTO',
'					v_column_id     ',
'				FROM ',
'					APEX_APPLICATION_PAGE_IR_COL',
'				WHERE ',
'					REGION_ID = v_region_id',
'					AND COLUMN_ALIAS  = C_ATTR_COLUMN_NAME;',
'			ELSE',
'				v_column_id := ''Not supported'';',
'		END CASE;',
'	EXCEPTION ',
'		WHEN NO_DATA_FOUND THEN ',
'			v_error := ''Pretius Smart Checkbox Column: ''||C_ATTR_COLUMN_NAME||'' column does not exist in affected report region. Contact application administrator.'';',
'		WHEN TOO_MANY_ROWS THEN ',
'			v_error := ''Pretius Smart Checkbox Column: More than one ''||C_ATTR_COLUMN_NAME||'' column found. Contact application administrator.'';',
'	END;',
'	',
'	APEX_JAVASCRIPT.ADD_LIBRARY (',
'		p_name      => ''smartCheckboxColumn'',',
'		p_directory => p_plugin.file_prefix,',
'		p_version   => null ',
'	);',
'',
'	IF C_ATTR_SELECTION_COLOR IS NOT NULL THEN',
'		v_css := ''##region-static-id# tr.pscc-selected-row td { background-color: #selected-color#!important; }',
'							##region-static-id# tr.pscc-selected-row:hover td { background-color: #selected-color#!important; } '';',
'		v_css := replace(v_css,''#selected-color#'', C_ATTR_SELECTION_COLOR); ',
'		v_css := replace(v_css,''#region-static-id#'', v_region_static_id);',
'		apex_css.add (',
'			p_css => v_css,',
'			p_key => ''smartCheckboxColumn''||v_region_static_id',
'		);',
'	END IF;',
'					',
'	v_result.ajax_identifier     := apex_plugin.get_ajax_identifier;     ',
'',
'	IF v_error IS NULL THEN     ',
'		v_result.javascript_function := ',
'			''function(){ ',
'				let ',
'					pluginInstanceId = ''''''||v_region_static_id||''_''||v_column_id||''_pscc'''';',
'				$(''''<div id="''''+pluginInstanceId+''''"></div>'''').appendTo(''''body'''');',
'				$(''''#''''+pluginInstanceId).smartCheckboxColumn( {''																	||',
'						apex_javascript.add_attribute(''ajaxIdentifier'',				v_result.ajax_identifier)						||       ',
'						apex_javascript.add_attribute(''selectionSettings'',			C_ATTR_SELECTION_SETTINGS)						||',
'						apex_javascript.add_attribute(''columnName'',					APEX_ESCAPE.HTML(C_ATTR_COLUMN_NAME) )			||',
'						apex_javascript.add_attribute(''storageItemName'',			C_ATTR_STORAGE_ITEM)							||',
'						apex_javascript.add_attribute(''storageCollectionName'',		APEX_ESCAPE.HTML(C_ATTR_STORAGE_COLLECTION) )	||',
'						apex_javascript.add_attribute(''valueSeparator'',				APEX_ESCAPE.HTML(C_ATTR_VALUE_SEPARATOR) )		||',
'						apex_javascript.add_attribute(''selectionColor'',				C_ATTR_SELECTION_COLOR)							||',
'						apex_javascript.add_attribute(''limitSelection'',				C_ATTR_LIMIT_SELECTION)							||',
'						apex_javascript.add_attribute(''itemAutoSubmit'',				C_ATTR_AUTO_SUBMIT_ITEM)						||    ',
'						apex_javascript.add_attribute(''emptyCheckboxIcon'',			C_ATTR_EMPTY_CHECKBOX_ICON)						||   ',
'						apex_javascript.add_attribute(''selectedCheckboxIcon'',		C_ATTR_SELECTED_CHECKBOX_ICON)					||   ',
'						apex_javascript.add_attribute(''additionalCollectionColumns'',		C_ATTR_COLLECTION_COLUMNS)					||   ',
'						',
'						apex_javascript.add_attribute(''regionId'',					v_region_static_id)								||          ',
'						apex_javascript.add_attribute(''regionTemplate'',				v_region_template)								||',
'						apex_javascript.add_attribute(''reportType'',					v_report_type )									||',
'						apex_javascript.add_attribute(''reportTemplate'',				v_report_template )								||  ',
'						apex_javascript.add_attribute(''columnId'',					v_column_id, false, false )						||          ',
'				''});',
'			}'';',
'	ELSE ',
'		v_result.javascript_function := ',
'			''function(){',
'				apex.message.clearErrors();',
'				apex.message.showErrors({',
'					type:       "error",',
'					location:   "page",',
'					message:    "'' || v_error ||''",',
'					unsafe:     false',
'				});',
'			}'';',
'	END IF;',
'',
'	return v_result;',
'EXCEPTION',
'	WHEN OTHERS THEN ',
'		apex_error.add_error (',
'			p_message          => ''Pretius Smart Checkbox Column: Unidentified error occured. </br> ',
'														 SQLERRM: ''|| SQLERRM || ''</br> ',
'														 Contact application administrator.'',',
'			p_display_location => apex_error.c_on_error_page  ',
'		);',
'',
'END f_render;',
'',
'FUNCTION f_ajax( ',
'	p_dynamic_action IN apex_plugin.t_dynamic_action,',
'	p_plugin         IN apex_plugin.t_plugin',
') return apex_plugin.t_dynamic_action_ajax_result',
'AS',
'	v_selected_values  APEX_APPLICATION_GLOBAL.VC_ARR2 DEFAULT APEX_APPLICATION.G_F01;',
'	v_extra_values     APEX_APPLICATION_GLOBAL.VC_ARR2 DEFAULT APEX_APPLICATION.G_F02;',
'	',
'	type t_extraValues is table of APEX_APPLICATION_GLOBAL.VC_ARR2;',
'	tr_extraValues t_extraValues := t_extraValues();',
'	type t_varchars is table of varchar2(4000) index by PLS_INTEGER;',
'	tr_varchars t_varchars;',
'',
'	v_ajax_command     varchar2(30)  DEFAULT APEX_APPLICATION.G_X01;',
'	v_save_to_coll     varchar2(30)  DEFAULT APEX_APPLICATION.G_X02;',
'	v_collection_name  varchar2(255) DEFAULT upper(APEX_APPLICATION.G_X03);',
'	v_collection_query varchar2(4000);',
'	v_ref_cur          sys_refcursor;',
'	v_result           apex_plugin.t_dynamic_action_ajax_result;',
'	v_array_count number;',
'BEGIN',
'	--debug',
'	IF apex_application.g_debug THEN',
'		apex_plugin_util.debug_dynamic_action (',
'			p_plugin         => p_plugin,',
'			p_dynamic_action => p_dynamic_action',
'		);',
'	END IF;',
'',
'    for i in 1..v_extra_values.count loop',
'        v_extra_values(i) := replace(v_extra_values(i), ''undefined'', null);',
'        --apex_debug.message(''Pretius Smart Checkbox Column: ''|| v_extra_values(i));',
'    end loop;',
'    ',
'	for extVal in (select COLUMN_VALUE, ROWNUM from table(v_extra_values)) loop --inifni',
'		for val in (select replace(COLUMN_VALUE, ''undefined'', null) as COLUMN_VALUE, ROWNUM from table(apex_string.split(v_extra_values(extVal.ROWNUM), '':'')) ) -- 3',
'		loop',
'			begin',
'				tr_varchars(val.ROWNUM) := tr_varchars(val.ROWNUM) || '':'' || val.COLUMN_VALUE;',
'			exception',
'				when no_data_found then',
'					tr_varchars(val.ROWNUM) := val.COLUMN_VALUE;',
'			end;',
'			tr_extraValues.extend;',
'			tr_extraValues(val.ROWNUM) := apex_util.STRING_TO_TABLE(tr_varchars(val.ROWNUM), '':'');',
'		end loop;       ',
'	end loop;',
'',
'',
'	CASE upper(v_ajax_command)',
'		WHEN ''GET'' THEN',
'			open v_ref_cur for',
'				SELECT',
'					C001 as "checkbox_value",',
'					nvl(C002, ''undefined'') || '':'' ||',
'					nvl(c003, ''undefined'') || '':'' ||',
'					nvl(c004, ''undefined'') || '':'' ||',
'					nvl(c005, ''undefined'') || '':'' ||',
'					nvl(c006, ''undefined'') || '':'' ||',
'					nvl(c007, ''undefined'') || '':'' ||',
'					nvl(c008, ''undefined'') || '':'' ||',
'					nvl(c009, ''undefined'') || '':'' ||',
'					nvl(c010, ''undefined'') || '':'' ||',
'					nvl(c011, ''undefined'') || '':'' ||',
'					nvl(c012, ''undefined'') || '':'' ||',
'					nvl(c013, ''undefined'') || '':'' ||',
'					nvl(c014, ''undefined'') || '':'' ||',
'					nvl(c015, ''undefined'') || '':'' ||',
'					nvl(c016, ''undefined'') || '':'' ||',
'					nvl(c017, ''undefined'') || '':'' ||',
'					nvl(c018, ''undefined'') || '':'' ||',
'					nvl(c019, ''undefined'') || '':'' ||',
'					nvl(c020, ''undefined'') || '':'' ||',
'					nvl(c021, ''undefined'') || '':'' ||',
'					nvl(c022, ''undefined'') || '':'' ||',
'					nvl(c023, ''undefined'') || '':'' ||',
'					nvl(c024, ''undefined'') || '':'' ||',
'					nvl(c025, ''undefined'') || '':'' ||',
'					nvl(c026, ''undefined'') || '':'' ||',
'					nvl(c027, ''undefined'') || '':'' ||',
'					nvl(c028, ''undefined'') || '':'' ||',
'					nvl(c029, ''undefined'') || '':'' ||',
'					nvl(c030, ''undefined'') || '':'' ||',
'					nvl(c031, ''undefined'') || '':'' ||',
'					nvl(c032, ''undefined'') || '':'' ||',
'					nvl(c033, ''undefined'') || '':'' ||',
'					nvl(c034, ''undefined'') || '':'' ||',
'					nvl(c035, ''undefined'') || '':'' ||',
'					nvl(c036, ''undefined'') || '':'' ||',
'					nvl(c037, ''undefined'') || '':'' ||',
'					nvl(c038, ''undefined'') || '':'' ||',
'					nvl(c039, ''undefined'') || '':'' ||',
'					nvl(c040, ''undefined'') || '':'' ||',
'					nvl(c041, ''undefined'') || '':'' ||',
'					nvl(c042, ''undefined'') || '':'' ||',
'					nvl(c043, ''undefined'') || '':'' ||',
'					nvl(c044, ''undefined'') || '':'' ||',
'					nvl(c045, ''undefined'') || '':'' ||',
'					nvl(c046, ''undefined'') || '':'' ||',
'					nvl(c047, ''undefined'') || '':'' ||',
'					nvl(c048, ''undefined'') || '':'' ||',
'					nvl(c049, ''undefined'') || '':'' ||',
'					nvl(c050, ''undefined'') as "extra_values"',
'				FROM',
'					APEX_COLLECTIONS',
'				WHERE',
'					COLLECTION_NAME = v_collection_name;',
'',
'			apex_json.open_object;',
'				apex_json.write(''selectedValues'', v_ref_cur);',
'				apex_json.write(''status'', ''Ok'');',
'				apex_json.write(''message'', ''Ok'');',
'			apex_json.close_object;',
'			--close v_ref_cur;',
'',
'		WHEN ''SET'' THEN',
'     ',
'			IF upper(v_save_to_coll) = ''TRUE'' THEN',
'				APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION( v_collection_name );',
'',
'        		v_array_count := tr_extraValues.COUNT;',
'',
'				APEX_COLLECTION.ADD_MEMBERS(',
'					p_collection_name => v_collection_name,',
'					p_c001            => v_selected_values,',
'					p_c002 => case when v_array_count >= 1 then tr_extraValues(1) else null end,',
'					p_c003 => case when v_array_count >= 2 then tr_extraValues(2) else null end,',
'					p_c004 => case when v_array_count >= 3 then tr_extraValues(3) else null end,',
'					p_c005 => case when v_array_count >= 4 then tr_extraValues(4) else null end,',
'					p_c006 => case when v_array_count >= 5 then tr_extraValues(5) else null end,',
'					p_c007 => case when v_array_count >= 6 then tr_extraValues(6) else null end,',
'					p_c008 => case when v_array_count >= 7 then tr_extraValues(7) else null end,',
'					p_c009 => case when v_array_count >= 8 then tr_extraValues(8) else null end,',
'					p_c010 => case when v_array_count >= 9 then tr_extraValues(9) else null end,',
'					p_c011 => case when v_array_count >= 10 then tr_extraValues(10) else null end,',
'					p_c012 => case when v_array_count >= 11 then tr_extraValues(11) else null end,',
'					p_c013 => case when v_array_count >= 12 then tr_extraValues(12) else null end,',
'					p_c014 => case when v_array_count >= 13 then tr_extraValues(13) else null end,',
'					p_c015 => case when v_array_count >= 14 then tr_extraValues(14) else null end,',
'					p_c016 => case when v_array_count >= 15 then tr_extraValues(15) else null end,',
'					p_c017 => case when v_array_count >= 16 then tr_extraValues(16) else null end,',
'					p_c018 => case when v_array_count >= 17 then tr_extraValues(17) else null end,',
'					p_c019 => case when v_array_count >= 18 then tr_extraValues(18) else null end,',
'					p_c020 => case when v_array_count >= 19 then tr_extraValues(19) else null end,',
'					p_c021 => case when v_array_count >= 20 then tr_extraValues(20) else null end,',
'					p_c022 => case when v_array_count >= 21 then tr_extraValues(21) else null end,',
'					p_c023 => case when v_array_count >= 22 then tr_extraValues(22) else null end,',
'					p_c024 => case when v_array_count >= 23 then tr_extraValues(23) else null end,',
'					p_c025 => case when v_array_count >= 24 then tr_extraValues(24) else null end,',
'					p_c026 => case when v_array_count >= 25 then tr_extraValues(25) else null end,',
'					p_c027 => case when v_array_count >= 26 then tr_extraValues(26) else null end,',
'					p_c028 => case when v_array_count >= 27 then tr_extraValues(27) else null end,',
'					p_c029 => case when v_array_count >= 28 then tr_extraValues(28) else null end,',
'					p_c030 => case when v_array_count >= 29 then tr_extraValues(29) else null end,',
'					p_c031 => case when v_array_count >= 30 then tr_extraValues(30) else null end,',
'					p_c032 => case when v_array_count >= 31 then tr_extraValues(31) else null end,',
'					p_c033 => case when v_array_count >= 32 then tr_extraValues(32) else null end,',
'					p_c034 => case when v_array_count >= 33 then tr_extraValues(33) else null end,',
'					p_c035 => case when v_array_count >= 34 then tr_extraValues(34) else null end,',
'					p_c036 => case when v_array_count >= 35 then tr_extraValues(35) else null end,',
'					p_c037 => case when v_array_count >= 36 then tr_extraValues(36) else null end,',
'					p_c038 => case when v_array_count >= 37 then tr_extraValues(37) else null end,',
'					p_c039 => case when v_array_count >= 38 then tr_extraValues(38) else null end,',
'					p_c040 => case when v_array_count >= 39 then tr_extraValues(39) else null end,',
'					p_c041 => case when v_array_count >= 40 then tr_extraValues(40) else null end,',
'					p_c042 => case when v_array_count >= 41 then tr_extraValues(41) else null end,',
'					p_c043 => case when v_array_count >= 42 then tr_extraValues(42) else null end,',
'					p_c044 => case when v_array_count >= 43 then tr_extraValues(43) else null end,',
'					p_c045 => case when v_array_count >= 44 then tr_extraValues(44) else null end,',
'					p_c046 => case when v_array_count >= 45 then tr_extraValues(45) else null end,',
'					p_c047 => case when v_array_count >= 46 then tr_extraValues(46) else null end,',
'					p_c048 => case when v_array_count >= 47 then tr_extraValues(47) else null end,',
'					p_c049 => case when v_array_count >= 48 then tr_extraValues(48) else null end,',
'					p_c050 => case when v_array_count >= 49 then tr_extraValues(49) else null end',
'				);',
'',
'			END IF;',
'            ',
'			apex_json.open_object;',
'				apex_json.write(''status'', ''Ok'');',
'				apex_json.write(''message'', ''APEX Collection updated successfully.'');',
'			apex_json.close_object;',
'',
'		WHEN ''SUBMIT'' THEN',
'			apex_json.open_object;',
'				apex_json.write(''status'', ''Ok'');',
'				apex_json.write(''message'', ''APEX Item submitted successfully.'');',
'			apex_json.close_object;',
'		ELSE',
'			apex_json.open_object;',
'				apex_json.write(''status'', ''Ok'');',
'				apex_json.write(''message'', ''No command for AJAX Callback.'');',
'			apex_json.close_object;',
'	END CASE;',
'',
'	return v_result;',
'',
'EXCEPTION',
'	WHEN OTHERS THEN',
'		apex_json.open_object; ',
'		apex_json.write(''status'', ''Error'');',
'		apex_json.write(''message'', ''Error occured'');           ',
'		apex_json.write(''SQLERRM'', SQLERRM);',
'		apex_json.close_object;',
'		-- cleaning up',
'		apex_json.close_all;',
'		close v_ref_cur;',
'        ',
'        apex_debug.error(''Pretius Smart Checkbox Column: ajax error - %s'', sqlerrm);',
'END f_ajax;',
''))
,p_api_version=>2
,p_render_function=>'f_render'
,p_ajax_function=>'f_ajax'
,p_standard_attributes=>'REGION:REQUIRED:ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p> Use this plugin to change chosen report column to interactive checkbox column. </p>',
'<p> Configure the plugin to manage selection behavior and storage settings of selected values </b>'))
,p_version_identifier=>'1.2.0'
,p_about_url=>'https://github.com/Pretius/pretius-smart-checkbox-column'
,p_files_version=>14
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(98211814830216593)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
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
 p_id=>wwv_flow_api.id(98221804090218630)
,p_plugin_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_display_sequence=>10
,p_display_value=>'Store selected values in APEX Item'
,p_return_value=>'STORE_IN_ITEM'
,p_help_text=>'Checking this attribute will cause all selected values to be stored in APEX Item. Item needs to be provided in separate attribute ("APEX Item to store selected values").'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(98231824250219848)
,p_plugin_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_display_sequence=>20
,p_display_value=>'Store selected values in APEX Collection'
,p_return_value=>'STORE_IN_COLLECTION'
,p_help_text=>'Checking this attribute will cause all selected values to be stored in APEX collection. Collection name can be defined in separate attribute ("APEX Collection name to store selected values"). Default collection name is PX_SELECTED_VALUES where X is a'
||'n application page number where the plugin instance exists. It is recommanded to change the defalut value, especially when there are more than one plugin instance existing on the same page.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(98241780776221738)
,p_plugin_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_display_sequence=>30
,p_display_value=>'Allow multiple selection'
,p_return_value=>'ALLOW_MULTIPLE'
,p_help_text=>'Check this attribute to allow for selecting mutliple rows at once. When this checkbox is left empty, only one row can be selected at the same time and checkbox in the header is disabled.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(98251795669223220)
,p_plugin_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_display_sequence=>40
,p_display_value=>'Select with click on row'
,p_return_value=>'SELECT_ON_ROW_CLICK'
,p_help_text=>'Check this attribute to allow for selecting checkboxes when clicked anywhere on a row.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(94220941893597906)
,p_plugin_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_display_sequence=>50
,p_display_value=>'Custom checkbox style'
,p_return_value=>'CUSTOM_CHECKBOX_STYLE'
,p_help_text=>'When checked plugin will render icons instead of standard HTML checkboxes.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(94471095199511919)
,p_plugin_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_display_sequence=>60
,p_display_value=>'IR Limit column width'
,p_return_value=>'IR_LIMIT_COL_WIDTH'
,p_help_text=>'Automatically adjust checkbox column width to avoid empty space. Applicable only to Interactive Report.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(98261790658230670)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
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
 p_id=>wwv_flow_api.id(98271855057234481)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'APEX Item to store selected values'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Application page item that will be used to store currently selected row(s). Selection is stored as text and values are separated with character defined in attribute "Value separator" (default ":"). </p>',
'<p>Because of maximum value length of APEX items, you may want Pretius Smart checkbox plugin to prevent from exceeding this limit. In this case make sure that "Limit selection length to 4000 Bytes" attribute is set to "Yes". </p>',
'<p> Use "Auto submit storage item" to automatically submit item value to APEX session state. </p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(98281769994237426)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'APEX Collection name to store selected values'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_COLLECTION'
,p_text_case=>'UPPER'
,p_help_text=>'Specify name of APEX collection that will be used to store currently selected row(s). Each selected row value is stored in separate collection member in varchar2 column "C001". Default collection name is PX_SELECTED_VALUES where X is an application p'
||'age number where the plugin instance exists. It is recommanded to change the defalut value, especially when there is more than one plugin instance existing on the same page.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(98282083199240512)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
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
,p_depending_on_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p> Separator for subsequent selected values when stored in APEX item. Default separator is ":". </p>',
'<p> Maximum length of separator is 5 characters. </p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(98291858238246696)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
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
 p_id=>wwv_flow_api.id(100682174990654298)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Limit selection length to 4000 Bytes'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_is_common=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>'Because of maximum value length of APEX items, you may want Pretius Smart checkbox plugin to prevent from exceeding this limit. In this case set this attribute is set to "Yes". When the limit is reached, all selected values above the limit will be tr'
||'uncated and plugin will trigger an event "Maximum selection length exceeded".'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(100841654972523617)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Auto submit storage item'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_is_common=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>'Set this attribute to "Yes" to automatically submit item value to APEX session state anytime selection is changed.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(94240695039637445)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Empty checkbox icon'
,p_attribute_type=>'ICON'
,p_is_required=>true
,p_default_value=>'fa-square-o'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'CUSTOM_CHECKBOX_STYLE'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p><ul>',
'  <li> fa-square-o </li>',
'  <li> fa-circle-o </li>',
'  <li> fa-heart-o </li>',
'</ul></p>'))
,p_help_text=>'Define APEX icon class that will be used instead of standard HTML checkbox input element. In this field provide icon class to represent not selected / empty state of the checkbox.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(94241245893640699)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Selected checkbox icon'
,p_attribute_type=>'ICON'
,p_is_required=>true
,p_default_value=>'fa-check-square-o'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'CUSTOM_CHECKBOX_STYLE'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p><ul>',
'  <li> fa-square </li>',
'  <li> fa-circle </li>',
'  <li> fa-heart </li>',
'</ul></p>'))
,p_help_text=>'Define APEX icon class that will be used instead of standard HTML checkbox input element. In this field provide icon class to represent selected state of the checkbox.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(31990220921498048)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Additional columns'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(98211814830216593)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_COLLECTION'
,p_examples=>'COLUMN_STATIC_ID1:COLUMN_STATIC_ID2:COLUMN_STATIC_ID3'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Columns to be put into collection along with replaced column.',
'Static IDs of columns should be typed with colon (:) as separator.',
'',
'Columns can be not displayed by deselecting them from Actions menu, however those columns cannot be defined as "Hidden column".',
'Following columns will be put into collection to next C*** collection columns starting with C002.'))
);
end;
/
begin
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(100811663993420766)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
,p_name=>'max_selection_length_exceeded'
,p_display_name=>'Maximum selection length exceeded'
);
null;
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A2A20506C7567696E3A205072657469757320536D61727420436865636B626F7820436F6C756D6E0A2A2056657273696F6E3A20312E322E300A2A0A2A20417574686F723A204164616D204B6965727A6B6F77736B690A2A204D61696C3A20616B69';
wwv_flow_api.g_varchar2_table(2) := '65727A6B6F77736B6940707265746975732E636F6D0A2A20547769747465723A20615F6B6965727A6B6F77736B690A2A20426C6F673A200A2A0A2A20446570656E64733A0A2A20202020617065782F64656275672E6A730A2A0920617065782F6576656E';
wwv_flow_api.g_varchar2_table(3) := '742E6A730A2A204368616E6765733A0A2A09312E302E30202D20496E697469616C2052656C656173650A2A09312E312E30202D204E65772066756E6374696F6E616C6965746965732061646465640A2A0909092A20537570706F727420666F72206D756C';
wwv_flow_api.g_varchar2_table(4) := '7469706C6520706C7567696E20696E7374616E636573206F6E207468652073616D65207265706F72740A2A0909092A20437573746F6D20636865636B626F7865732076697375616C697A6174696F6E730A2A0909092A204175746F206C696D6974696E67';
wwv_flow_api.g_varchar2_table(5) := '20636865636B626F7820636F6C756D6E20776964746820666F7220496E746572616374697665205265706F72740A2A09312E312E31202D20506174636820666F720A2A0909092A2049737375652023310A2A0909092A2042726F6B656E2073656C656374';
wwv_flow_api.g_varchar2_table(6) := '20616C6C20636865636B626F7820616674657220706167652072656672657368207769746820616C6C20636865636B626F7865732073656C65637465640A2A09312E322E30202D204E65772066756E6374696F6E616C69746965732061646465640A2A09';
wwv_flow_api.g_varchar2_table(7) := '09092A204D756C7469706C6520636F6C756D6E73206F6620746865207265706F72742063616E206E6F772062652073746F72656420696E204150455820636F6C6C656374696F6E20616C6F6E6720776974682073656C656374656420636865636B626F78';
wwv_flow_api.g_varchar2_table(8) := '2076616C7565730A2A2F0A0A2866756E6374696F6E202864656275672C2024297B0A092275736520737472696374223B0A0A09242E776964676574282022707265746975732E736D617274436865636B626F78436F6C756D6E222C207B0A09092F2F2063';
wwv_flow_api.g_varchar2_table(9) := '6F6E7374616E74730A0909435F504C5547494E5F4E414D452020202020203A20275072657469757320536D61727420636865636B626F7820636F6C756D6E272C0A0909435F4C4F475F505245464958202020202020203A2027536D61727420636865636B';
wwv_flow_api.g_varchar2_table(10) := '626F7820636F6C756D6E3A20272C0A0909435F4C4F475F4C564C5F4552524F52202020203A2064656275672E4C4F475F4C4556454C2E4552524F522C2020202020202020202F2F2076616C756520312028656E642D757365722920200A0909435F4C4F47';
wwv_flow_api.g_varchar2_table(11) := '5F4C564C5F5741524E494E4720203A2064656275672E4C4F475F4C4556454C2E5741524E2C202020202020202020202F2F2076616C756520322028646576656C6F706572290A0909435F4C4F475F4C564C5F4445425547202020203A2064656275672E4C';
wwv_flow_api.g_varchar2_table(12) := '4F475F4C4556454C2E494E464F2C202020202020202020202F2F2076616C7565203420286465627567290A0909435F4C4F475F4C564C5F3620202020202020203A2064656275672E4C4F475F4C4556454C2E4150505F54524143452C20202020202F2F20';
wwv_flow_api.g_varchar2_table(13) := '76616C75652036200A0909435F4C4F475F4C564C5F3920202020202020203A2064656275672E4C4F475F4C4556454C2E454E47494E455F54524143452C20202F2F2076616C756520390A0A0909435F535550504F525445445F5245504F52545F54595045';
wwv_flow_api.g_varchar2_table(14) := '5320202020202020203A205B27436C6173736963205265706F7274272C2027496E746572616374697665205265706F7274275D2C0A0909435F444953504C41595F504147455F4552524F525F4D455353414745532020203A20747275652C0A0909435F45';
wwv_flow_api.g_varchar2_table(15) := '4E445F555345525F4552524F525F5052454649582020202020202020203A2027436865636B626F782066756E6374696F6E616C697479206572726F723A20272C0A0909435F454E445F555345525F4552524F525F5355464649582020202020202020203A';
wwv_flow_api.g_varchar2_table(16) := '2027436F6E7461637420796F75722061646D696E6973747261746F722E272C0A0909435F4552524F525F5245504F52545F4E4F545F535550504F52544544202020203A202743686F73656E20726567696F6E206973206E6F742061207265706F7274206F';
wwv_flow_api.g_varchar2_table(17) := '7220746865207265706F72742074797065206973206E6F7420737570706F727465642E20272C0A0909435F4552524F525F4E4F5F434F4C554D4E5F464F554E442020202020202020203A20275265706F727420636F6C756D6E20746F20646973706C6179';
wwv_flow_api.g_varchar2_table(18) := '20636865636B626F78657320646F6573206E6F742065786973742E20272C0A0909435F4552524F525F434845434B424F5845535F444F5F4E4F545F4558495354203A20274E6F20636865636B626F7865732065786973742E20272C0A0909435F4552524F';
wwv_flow_api.g_varchar2_table(19) := '525F4954454D5F444F45535F4E4F545F455849535420202020203A202741504558206974656D2063686F73656E20746F2073746F72652073656C65637465642076616C75657320646F6573206E6F742065786973742E20272C0A0909435F4552524F525F';
wwv_flow_api.g_varchar2_table(20) := '414A41585F53544F52455F4641494C5552452020202020203A202753746F72696E672063757272656E746C792073656C656374656420726F777320686173206661696C65642E20272C0A0909435F4552524F525F414A41585F524541445F4641494C5552';
wwv_flow_api.g_varchar2_table(21) := '45202020202020203A202752656164696E672063757272656E746C792073656C656374656420726F777320686173206661696C65642E20272C0A0909435F53454C45435445445F524F575F434C4153532020202020202020202020203A2027707363632D';
wwv_flow_api.g_varchar2_table(22) := '73656C65637465642D726F77272C0A0909435F53544F524147455F4954454D5F4D41585F42595445535F434F554E5420203A20343030302C0A0909435F4556454E545F4D41585F53454C454354494F4E5F455843454445442020203A20276D61785F7365';
wwv_flow_api.g_varchar2_table(23) := '6C656374696F6E5F6C656E6774685F6578636565646564272C0A0A09096F7074696F6E733A207B0A09097D2C0A0A0A09092F2F206372656174652066756E6374696F6E0A09095F6372656174653A2066756E6374696F6E28297B0A090909766172207365';
wwv_flow_api.g_varchar2_table(24) := '6C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20275374617274696E672077696467657420696E697469616C697A6174696F6E';
wwv_flow_api.g_varchar2_table(25) := '2E2E2E272C20276F7074696F6E733A20272C2073656C662E6F7074696F6E73293B0A09090973656C662E7265706F727450726F70657274696573203D207B0A0909090922726567696F6E4964220909093A2073656C662E6F7074696F6E732E726567696F';
wwv_flow_api.g_varchar2_table(26) := '6E49642C0A0909090922726567696F6E54656D706C6174652220093A2073656C662E6F7074696F6E732E726567696F6E54656D706C6174652C0A09090909227265706F7274547970652209093A2073656C662E6F7074696F6E732E7265706F7274547970';
wwv_flow_api.g_varchar2_table(27) := '652C0A09090909227265706F727454656D706C61746522093A2073656C662E6F7074696F6E732E7265706F727454656D706C6174652C20202020202020200A0909097D3B0A09090973656C662E636F6C756D6E50726F70657274696573203D207B0A0909';
wwv_flow_api.g_varchar2_table(28) := '090922636F6C756D6E4E616D652209093A2073656C662E6F7074696F6E732E636F6C756D6E4E616D652C0A0909090922636F6C756D6E4964220909093A2073656C662E6F7074696F6E732E636F6C756D6E49642C0A0909090922636F6C756D6E496E6465';
wwv_flow_api.g_varchar2_table(29) := '782209093A2024282723272B73656C662E6F7074696F6E732E636F6C756D6E4964292E696E64657828292C0A090909092269724C696D6974436F6C576964746822093A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732021';
wwv_flow_api.g_varchar2_table(30) := '3D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F66282749525F4C494D49545F434F4C5F57494454482729203E202D312C200A0909097D3B0A09090973656C662E73656C656374696F';
wwv_flow_api.g_varchar2_table(31) := '6E50726F70657274696573203D207B0A0909090922616C6C6F774D756C7469706C6553656C656374696F6E22093A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E';
wwv_flow_api.g_varchar2_table(32) := '732E73656C656374696F6E53657474696E67732E696E6465784F662827414C4C4F575F4D554C5449504C452729203E202D312C0A090909092273656C6563744F6E436C69636B416E7977686572652209093A2073656C662E6F7074696F6E732E73656C65';
wwv_flow_api.g_varchar2_table(33) := '6374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F66282753454C4543545F4F4E5F524F575F434C49434B2729203E202D312C0A09090909227365';
wwv_flow_api.g_varchar2_table(34) := '6C656374696F6E436F6C6F72220909093A2073656C662E6F7074696F6E732E73656C656374696F6E436F6C6F722C0A0909090922637573746F6D436865636B626F785374796C652209093A2073656C662E6F7074696F6E732E73656C656374696F6E5365';
wwv_flow_api.g_varchar2_table(35) := '7474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F662827435553544F4D5F434845434B424F585F5354594C452729203E202D312C0A0909090922656D7074794368';
wwv_flow_api.g_varchar2_table(36) := '65636B626F7849636F6E220909093A2073656C662E6F7074696F6E732E656D707479436865636B626F7849636F6E2C0A090909092273656C6563746564436865636B626F7849636F6E2209093A2073656C662E6F7074696F6E732E73656C656374656443';
wwv_flow_api.g_varchar2_table(37) := '6865636B626F7849636F6E0A0909097D3B0A09090973656C662E73746F7261676550726F70657274696573203D207B0A090909092273746F726553656C6563746564496E4974656D220909202020203A2073656C662E6F7074696F6E732E73656C656374';
wwv_flow_api.g_varchar2_table(38) := '696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F66282753544F52455F494E5F4954454D2729203E202D312C0A090909092273746F726553656C6563';
wwv_flow_api.g_varchar2_table(39) := '746564496E436F6C6C656374696F6E2220202020203A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465';
wwv_flow_api.g_varchar2_table(40) := '784F66282753544F52455F494E5F434F4C4C454354494F4E2729203E202D312C20202020202020200A090909092273746F726167654974656D4E616D6522090909202020203A2073656C662E6F7074696F6E732E73746F726167654974656D4E616D652C';
wwv_flow_api.g_varchar2_table(41) := '0A09090909226974656D4175746F5375626D697422090909202020203A2073656C662E6F7074696F6E732E6974656D4175746F5375626D6974203D3D3D20275927203F2074727565203A2066616C73652C0A090909092273746F72616765436F6C6C6563';
wwv_flow_api.g_varchar2_table(42) := '74696F6E4E616D65220909202020203A2073656C662E6F7074696F6E732E73746F72616765436F6C6C656374696F6E4E616D652C0A090909092276616C7565536570617261746F7222090909202020203A2073656C662E6F7074696F6E732E76616C7565';
wwv_flow_api.g_varchar2_table(43) := '536570617261746F722C0A09090909226C696D697453656C656374696F6E22090909202020203A2073656C662E6F7074696F6E732E6C696D697453656C656374696F6E2C20200A09090909226164646974696F6E616C436F6C6C656374696F6E436F6C75';
wwv_flow_api.g_varchar2_table(44) := '6D6E73222020203A2073656C662E6F7074696F6E732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E7320200A0909097D3B0A0A0909096966202873656C662E5F636865636B49665265706F727454797065537570706F727465642829';
wwv_flow_api.g_varchar2_table(45) := '203D3D2066616C7365297B0A0909090973656C662E5F7468726F774572726F7228275F637265617465272C2073656C662E435F4552524F525F5245504F52545F4E4F545F535550504F525445442C2074727565293B0A0909097D0A090909696620287365';
wwv_flow_api.g_varchar2_table(46) := '6C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D203D3D20747275652026262073656C662E5F636865636B49664974656D4578697374732829203D3D2066616C7365297B0A0909090973656C662E5F74';
wwv_flow_api.g_varchar2_table(47) := '68726F774572726F7228275F637265617465272C2073656C662E435F4552524F525F4954454D5F444F45535F4E4F545F45584953542C2066616C7365293B0A0909097D0A0909090A0909092F2F20544F20444F202D2068616E646C652064696666657265';
wwv_flow_api.g_varchar2_table(48) := '6E7420636C6173736963207265706F72742074656D706C617465730A0909092F2F20544F20444F202D2068616E646C6520646966666572656E74207265706F72742074797065730A0A09090973656C662E726567696F6E24203D2024282723272B73656C';
wwv_flow_api.g_varchar2_table(49) := '662E7265706F727450726F706572746965732E726567696F6E4964293B0A0A09090973656C662E726567696F6E242E6F6E282761706578616674657272656672657368272C2066756E6374696F6E202829207B0A0909090964656275672E6D6573736167';
wwv_flow_api.g_varchar2_table(50) := '652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027416674657220726566726573682070726F63657373696E672E2E2E2027293B0A0909090973656C662E5F66696E64436865636B626F78436F';
wwv_flow_api.g_varchar2_table(51) := '6C756D6E28293B0A0909090973656C662E5F72656E646572436865636B626F78657328293B0A0909090973656C662E5F616464436C69636B4C697374656E65727328293B0A0909090973656C662E5F6170706C7953656C656374696F6E28293B0A090909';
wwv_flow_api.g_varchar2_table(52) := '7D293B0A0A09090973656C662E5F66696E64436865636B626F78436F6C756D6E28293B0A09090973656C662E5F72656E646572436865636B626F78657328293B0A09090973656C662E5F616464436C69636B4C697374656E65727328293B20202020200A';
wwv_flow_api.g_varchar2_table(53) := '09090973656C662E5F67657453746F72656456616C75657328293B0A0909090A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202757696467657420696E';
wwv_flow_api.g_varchar2_table(54) := '697469616C697A6564207375636365737366756C6C793A2027293B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20275265706F72743A20272C207365';
wwv_flow_api.g_varchar2_table(55) := '6C662E726567696F6E24293B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20274865616465723A20272C2073656C662E636F6C756D6E486561646572';
wwv_flow_api.g_varchar2_table(56) := '24293B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202743656C6C733A2027202C2073656C662E636F6C756D6E43656C6C7324293B2020202020200A';
wwv_flow_api.g_varchar2_table(57) := '09097D2C0A090A09092F2F206A5175657279207769646765742070726976617465206D6574686F64730A0A09095F636865636B49665265706F727454797065537570706F727465643A2066756E6374696F6E28297B0A0909097661722073656C66203D20';
wwv_flow_api.g_varchar2_table(58) := '746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C2027436865636B696E67206966207265706F7274207479706520697320737570706F727465642E2E2E';
wwv_flow_api.g_varchar2_table(59) := '27293B0A0A09090972657475726E2073656C662E435F535550504F525445445F5245504F52545F54595045532E696E636C756465732873656C662E7265706F727450726F706572746965732E7265706F727454797065293B20202020200A09097D2C0A0A';
wwv_flow_api.g_varchar2_table(60) := '09095F636865636B49664974656D4578697374733A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F';
wwv_flow_api.g_varchar2_table(61) := '5052454649582C2027436865636B696E672069662061706578206974656D206578697374732E2E2E27293B0A0A09090972657475726E20617065782E6974656D2873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E';
wwv_flow_api.g_varchar2_table(62) := '616D65292E6E6F64653B20202020200A09097D2C0A0A09095F66696E64436865636B626F78436F6C756D6E3A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E43';
wwv_flow_api.g_varchar2_table(63) := '5F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202746696E64696E6720636865636B626F7820636F6C756D6E2E2E2E27293B0A0A0909090A09090973656C662E636F6C756D6E48656164657224203D2073656C662E72656769';
wwv_flow_api.g_varchar2_table(64) := '6F6E242E66696E64282774685B69643D22272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E49642B27225D27293B0A09090973656C662E636F6C756D6E43656C6C732420203D2073656C662E726567696F6E242E66696E642827';
wwv_flow_api.g_varchar2_table(65) := '74645B686561646572733D22272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E49642B27225D27293B0A09097D2C0A0A09092F2F2046756E6374696F6E2072656E6465727320636865636B626F78657320617661696C61626C65';
wwv_flow_api.g_varchar2_table(66) := '20616674657220696E2073656C662E63656C6C436865636B626F7865732420616E642073656C662E686561646572436865636B626F78240A09095F72656E646572436865636B626F7865733A2066756E6374696F6E28297B0A0909097661722073656C66';
wwv_flow_api.g_varchar2_table(67) := '203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202752656E646572696E6720636865636B626F7865732E2E2E27293B0A0909090A0909096966';
wwv_flow_api.g_varchar2_table(68) := '202873656C662E73656C656374696F6E50726F706572746965732E637573746F6D436865636B626F785374796C6529207B0A090909092F2F2072656E646572696E6720636F6C756D6E20636865636B626F786573202D20637573746F6D207374796C650A';
wwv_flow_api.g_varchar2_table(69) := '0909090973656C662E636F6C756D6E43656C6C73242E656163682866756E6374696F6E28297B0A09090909096C6574200A09090909090963656C6C2420202020202020202020203D20242874686973292C0A09090909090963656C6C56616C7565202020';
wwv_flow_api.g_varchar2_table(70) := '202020203D2063656C6C242E7465787428292C0A09090909090976616C756541747472696275746520203D20272076616C75653D22272B63656C6C56616C75652B272220273B0A0909090909090A0909090909696628747970656F662073656C662E7374';
wwv_flow_api.g_varchar2_table(71) := '6F7261676550726F706572746965732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E73203D3D3D2027737472696E6727297B0A090909090909636F6E737420636F6C756D6E734944203D2073656C662E73746F7261676550726F7065';
wwv_flow_api.g_varchar2_table(72) := '72746965732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E732E73706C697428273A27293B0A0909090909094F626A6563742E76616C75657328636F6C756D6E734944292E666F72456163682820436F6C756D6E4944203D3E207B0A';
wwv_flow_api.g_varchar2_table(73) := '090909090909096C657420436F6C756D6E56616C7565203D2063656C6C242E706172656E7428292E66696E64282274645B686561646572733D27222B436F6C756D6E49442B22275D22292E7465787428293B0A0909090909090976616C75654174747269';
wwv_flow_api.g_varchar2_table(74) := '62757465202B3D20272027202B20436F6C756D6E4944202B20273D22272B436F6C756D6E56616C75652B272220273B0A0909090909097D293B0A09090909097D0A0A09090909096C657420636865636B626F7824203D202428273C7370616E20636C6173';
wwv_flow_api.g_varchar2_table(75) := '733D227073636320666120272B73656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E2B272220272B2076616C7565417474726962757465202B273E3C2F7370616E3E27293B0A090909090963656C6C';
wwv_flow_api.g_varchar2_table(76) := '242E68746D6C28636865636B626F7824293B0A090909097D293B0A0909090973656C662E63656C6C436865636B626F78657324203D2073656C662E636F6C756D6E43656C6C73242E66696E6428277370616E2E7073636327293B0A0A090909092F2F2072';
wwv_flow_api.g_varchar2_table(77) := '656E646572696E672068656164657220636865636B626F78202D20637573746F6D207374796C650A090909096C65740A0909090909636865636B626F7824202020203D202428273C7370616E20636C6173733D227073636320666120272B73656C662E73';
wwv_flow_api.g_varchar2_table(78) := '656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E2B27223E3C2F7370616E3E27293B0A0A0909090973656C662E636F6C756D6E486561646572242E66696E6428276127292E72656D6F766528293B0A0909090973';
wwv_flow_api.g_varchar2_table(79) := '656C662E636F6C756D6E486561646572242E66696E6428277370616E27292E72656D6F766528293B0A0909090973656C662E636F6C756D6E486561646572242E636F6E74656E747328292E66696C7465722866756E6374696F6E2829207B0A0909090909';
wwv_flow_api.g_varchar2_table(80) := '72657475726E20746869732E6E6F646554797065203D3D204E6F64652E544558545F4E4F44453B0A090909097D292E72656D6F766528293B202020200A0A0909090973656C662E636F6C756D6E486561646572242E617070656E6428636865636B626F78';
wwv_flow_api.g_varchar2_table(81) := '242E636C6F6E652829293B0A0909090973656C662E686561646572436865636B626F7824203D2073656C662E636F6C756D6E486561646572242E66696E6428277370616E2E7073636327293B0A0A0909097D20656C7365207B0A090909092F2F2072656E';
wwv_flow_api.g_varchar2_table(82) := '646572696E6720636F6C756D6E20636865636B626F786573202D207374616E646172642048544D4C0A0909090973656C662E636F6C756D6E43656C6C73242E656163682866756E6374696F6E28297B0A09090909096C6574200A09090909090963656C6C';
wwv_flow_api.g_varchar2_table(83) := '2420202020202020202020203D20242874686973292C0A09090909090963656C6C56616C7565202020202020203D2063656C6C242E7465787428292C0A09090909090976616C756541747472696275746520203D20272076616C75653D22272B63656C6C';
wwv_flow_api.g_varchar2_table(84) := '56616C75652B272220273B0A0909090909090A0909090909696628747970656F662073656C662E73746F7261676550726F706572746965732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E73203D3D3D2027737472696E6727297B0A';
wwv_flow_api.g_varchar2_table(85) := '090909090909636F6E737420636F6C756D6E734944203D2073656C662E73746F7261676550726F706572746965732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E732E73706C697428273A27293B0A0909090909094F626A6563742E';
wwv_flow_api.g_varchar2_table(86) := '76616C75657328636F6C756D6E734944292E666F72456163682820436F6C756D6E4944203D3E207B0A090909090909096C657420436F6C756D6E56616C7565203D2063656C6C242E706172656E7428292E66696E64282274645B686561646572733D2722';
wwv_flow_api.g_varchar2_table(87) := '2B436F6C756D6E49442B22275D22292E7465787428293B0A0909090909090976616C7565417474726962757465202B3D20272027202B20436F6C756D6E4944202B20273D22272B436F6C756D6E56616C75652B272220273B0A0909090909097D293B0A09';
wwv_flow_api.g_varchar2_table(88) := '090909097D0A0A09090909096C657420636865636B626F7824203D202428273C696E70757420747970653D22636865636B626F7822272B2076616C7565417474726962757465202B273E27293B0A090909090963656C6C242E68746D6C28636865636B62';
wwv_flow_api.g_varchar2_table(89) := '6F7824293B0A090909097D293B0A0909090973656C662E63656C6C436865636B626F78657324203D2073656C662E636F6C756D6E43656C6C73242E66696E642827696E7075745B747970653D22636865636B626F78225D27293B0A0A090909092F2F2072';
wwv_flow_api.g_varchar2_table(90) := '656E646572696E672068656164657220636865636B626F78202D207374616E646172642048544D4C0A090909096C65740A090909090964697361626C6564417474726962757465093D202173656C662E73656C656374696F6E50726F706572746965732E';
wwv_flow_api.g_varchar2_table(91) := '616C6C6F774D756C7469706C6553656C656374696F6E203F20272064697361626C65642027203A2027272C0A0909090909636865636B626F78242020202009093D202428273C696E70757420747970653D22636865636B626F7822272B2064697361626C';
wwv_flow_api.g_varchar2_table(92) := '65644174747269627574652B273E27293B0A0A0909090973656C662E636F6C756D6E486561646572242E66696E6428276127292E72656D6F766528293B0A0909090973656C662E636F6C756D6E486561646572242E66696E6428277370616E27292E7265';
wwv_flow_api.g_varchar2_table(93) := '6D6F766528293B0A0909090973656C662E636F6C756D6E486561646572242E636F6E74656E747328292E66696C7465722866756E6374696F6E2829207B0A090909090972657475726E20746869732E6E6F646554797065203D3D204E6F64652E54455854';
wwv_flow_api.g_varchar2_table(94) := '5F4E4F44453B0A090909097D292E72656D6F766528293B202020200A0A0909090973656C662E636F6C756D6E486561646572242E617070656E6428636865636B626F78242E636C6F6E652829293B0A0909090973656C662E686561646572436865636B62';
wwv_flow_api.g_varchar2_table(95) := '6F7824203D2073656C662E636F6C756D6E486561646572242E66696E642827696E7075745B747970653D22636865636B626F78225D27293B0A0909097D0A0A0909092F2F204C696D697420636F6C756D6E20776964746820666F72204952200A09090969';
wwv_flow_api.g_varchar2_table(96) := '66202873656C662E7265706F727450726F706572746965732E7265706F727454797065203D3D2027496E746572616374697665205265706F7274272026262073656C662E636F6C756D6E50726F706572746965732E69724C696D6974436F6C5769647468';
wwv_flow_api.g_varchar2_table(97) := '29207B0A0909090924280A09090909092723272B73656C662E7265706F727450726F706572746965732E726567696F6E4964202B20272074683A6E74682D6368696C6428272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E496E';
wwv_flow_api.g_varchar2_table(98) := '6465782B312B27292C2027202B0A09090909092723272B73656C662E7265706F727450726F706572746965732E726567696F6E4964202B20272074683A6E74682D6368696C6428272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D';
wwv_flow_api.g_varchar2_table(99) := '6E496E6465782B312B2729203E206469762C2027202B0A09090909092723272B73656C662E7265706F727450726F706572746965732E726567696F6E4964202B20272074683A6E74682D6368696C6428272B73656C662E636F6C756D6E50726F70657274';
wwv_flow_api.g_varchar2_table(100) := '6965732E636F6C756D6E496E6465782B312B2729203E20612C2027202B090909090A09090909092723272B73656C662E7265706F727450726F706572746965732E726567696F6E4964202B20272074643A6E74682D6368696C6428272B73656C662E636F';
wwv_flow_api.g_varchar2_table(101) := '6C756D6E50726F706572746965732E636F6C756D6E496E6465782B312B2729270A09090909292E637373287B20277769647468273A202734307078277D293B0A0909090A09090909617065782E6576656E742E747269676765722827626F6479272C2027';
wwv_flow_api.g_varchar2_table(102) := '6170657877696E646F77726573697A656427293B200A0909097D0A09090924282723272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E4964292E637373287B27766572746963616C2D616C69676E273A20276D6964646C65277D';
wwv_flow_api.g_varchar2_table(103) := '293B200A0A0909092F2F20666F7220736F6D6520726561736F6E2041504558204952206973206E6F74206265686176696E67206772656174207768656E2074686572652061726520616E79206368616E67657320696E207461626C652068656164657273';
wwv_flow_api.g_varchar2_table(104) := '0A0909092F2F20726573756C74696E6720696E20626C616E6B20737061636520616464656420756E64657220746865206865616465722E20526573697A696E67207468652077696E646F7720616C6C6F772049522077696467657420746F20726563616C';
wwv_flow_api.g_varchar2_table(105) := '63756C6174650A0909092F2F207370616365206E656564656420666F72206865616465727320616E6420666978207468652069737375652C20736F206C65742773206D616B652069742073696D706C6520616E64206A7573742073696D756C6174652077';
wwv_flow_api.g_varchar2_table(106) := '696E646F7720726573697A652E0A090909617065782E6576656E742E747269676765722827626F6479272C20276170657877696E646F77726573697A656427293B200A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F36';
wwv_flow_api.g_varchar2_table(107) := '2C2073656C662E435F4C4F475F5052454649582C202763656C6C436865636B626F786573243A20272C2073656C662E63656C6C436865636B626F78657324293B0A09097D2C0A0A09095F616464436C69636B4C697374656E6572733A2066756E6374696F';
wwv_flow_api.g_varchar2_table(108) := '6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C2027416464696E6720636C69636B206C697374656E65';
wwv_flow_api.g_varchar2_table(109) := '72732E2E2E27293B0A0A0909092F2F204164642063656C6C20636865636B626F78206C697374656E6572730A09090973656C662E63656C6C436865636B626F786573242E656163682866756E6374696F6E28297B0A090909096C6574200A090909090963';
wwv_flow_api.g_varchar2_table(110) := '6865636B626F7824203D20242874686973292C0A0909090909706172656E74526F77203D20242874686973292E636C6F736573742827747227293B0A0A090909096966202873656C662E73656C656374696F6E50726F706572746965732E73656C656374';
wwv_flow_api.g_varchar2_table(111) := '4F6E436C69636B416E797768657265297B0A09090909096966202873656C662E73656C656374696F6E50726F706572746965732E616C6C6F774D756C7469706C6553656C656374696F6E297B0A090909090909706172656E74526F772E6F6E2827636C69';
wwv_flow_api.g_varchar2_table(112) := '636B272C20242E70726F7879282073656C662E5F6D756C7469706C6553656C656374696F6E48616E646C65722C2073656C662C20636865636B626F782429293B202F2F2032202D20726F772073656C656374696F6E2C206D756C7469706C650A09090909';
wwv_flow_api.g_varchar2_table(113) := '097D20656C7365207B0A090909090909706172656E74526F772E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73696E676C6553656C656374696F6E48616E646C65722C2073656C662C20636865636B626F782429293B2020202F2F';
wwv_flow_api.g_varchar2_table(114) := '2031202D20726F772073656C656374696F6E2C2073696E676C650A09090909097D200A090909097D20656C7365207B0A09090909096966202873656C662E73656C656374696F6E50726F706572746965732E616C6C6F774D756C7469706C6553656C6563';
wwv_flow_api.g_varchar2_table(115) := '74696F6E297B0A090909090909636865636B626F78242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F6D756C7469706C6553656C656374696F6E48616E646C65722C2073656C662C20636865636B626F782429293B2020202F2F20';
wwv_flow_api.g_varchar2_table(116) := '33202D20636865636B626F782073656C656369746F6E2C2073696E676C650A09090909097D20656C7365207B0A090909090909636865636B626F78242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73696E676C6553656C656374';
wwv_flow_api.g_varchar2_table(117) := '696F6E48616E646C65722C2073656C662C20636865636B626F782429293B202F2F2034202D20636865636B626F782073656C656374696F6E2C206D756C7469706C652020200A09090909097D0A090909097D0A0909097D293B200A0909090A0909092F2F';
wwv_flow_api.g_varchar2_table(118) := '204164642068656164657220636865636B626F78206C697374656E65720A0909096966202873656C662E73656C656374696F6E50726F706572746965732E616C6C6F774D756C7469706C6553656C656374696F6E297B0A090909096966202873656C662E';
wwv_flow_api.g_varchar2_table(119) := '73656C656374696F6E50726F706572746965732E73656C6563744F6E436C69636B416E797768657265297B0A090909090973656C662E636F6C756D6E486561646572242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73656C6563';
wwv_flow_api.g_varchar2_table(120) := '74416C6C48616E646C65722C2073656C6629293B0A090909097D20656C7365207B0A090909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20276865616465';
wwv_flow_api.g_varchar2_table(121) := '7220636865636B626F782C20616464696E67206C697374656E65723A20272C2073656C662E686561646572436865636B626F7824293B0A090909090973656C662E686561646572436865636B626F78242E6F6E2827636C69636B272C20242E70726F7879';
wwv_flow_api.g_varchar2_table(122) := '282073656C662E5F73656C656374416C6C48616E646C65722C2073656C6629293B0A090909097D0A0909097D0A09097D2C0A0A09095F73696E676C6553656C656374696F6E48616E646C65723A2066756E6374696F6E2870436865636B626F78242C2070';
wwv_flow_api.g_varchar2_table(123) := '4576656E74297B0A090909766172200A0909090973656C6620203D20746869732C0A0909090976616C7565203D2070436865636B626F78242E61747472282776616C756527292C0A09090909657874726156616C756573203D2022223B0A090909646562';
wwv_flow_api.g_varchar2_table(124) := '75672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202753696E676C652073656C656374696F6E2068616E646C657220747269676765726564206279206576656E743A20272C';
wwv_flow_api.g_varchar2_table(125) := '20704576656E74293B0A0909090A09090970436865636B626F78242E656163682866756E6374696F6E2829207B0A09090909242E6561636828746869732E617474726962757465732C2066756E6374696F6E2829207B0A09090909092F2F20746869732E';
wwv_flow_api.g_varchar2_table(126) := '61747472696275746573206973206E6F74206120706C61696E206F626A6563742C2062757420616E2061727261790A09090909092F2F206F6620617474726962757465206E6F6465732C20776869636820636F6E7461696E20626F746820746865206E61';
wwv_flow_api.g_varchar2_table(127) := '6D6520616E642076616C75650A0909090909696628746869732E73706563696669656429207B0A0A090909090909696628747970656F662073656C662E73746F7261676550726F706572746965732E6164646974696F6E616C436F6C6C656374696F6E43';
wwv_flow_api.g_varchar2_table(128) := '6F6C756D6E73203D3D3D2027737472696E6727297B0A09090909090909636F6E737420636F6C756D6E734944203D2073656C662E73746F7261676550726F706572746965732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E732E746F';
wwv_flow_api.g_varchar2_table(129) := '4C6F7765724361736528292E73706C697428273A27293B0A090909090909096966202820242E696E417272617928746869732E6E616D652E746F4C6F7765724361736528292C20636F6C756D6E7349442920213D3D202D312029207B0A09090909090909';
wwv_flow_api.g_varchar2_table(130) := '09657874726156616C756573202B3D20746869732E76616C7565202B20273A270A090909090909097D0A0909090909097D0A09090909097D0A090909097D293B0A0909097D293B0A0A0909096966202873656C662E73656C656374656456616C7565732E';
wwv_flow_api.g_varchar2_table(131) := '696E636C756465732876616C75652929207B0A0909090973656C662E5F636C65617253656C656374656456616C75657328293B0A0909097D20656C7365207B0A0909090973656C662E5F636C65617253656C656374656456616C75657328293B0A090909';
wwv_flow_api.g_varchar2_table(132) := '0964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027657874726156616C75657320636865636B206265666F7265207075736820746F206164643A20272C206578';
wwv_flow_api.g_varchar2_table(133) := '74726156616C756573293B0A0909090973656C662E5F616464546F53656C656374656456616C7565732876616C75652C20657874726156616C756573293B0A0909097D0A0A09090973656C662E5F6170706C7953656C656374696F6E28293B0A09090973';
wwv_flow_api.g_varchar2_table(134) := '656C662E5F73746F726556616C75657328293B20200A09097D2C0A0A09095F6D756C7469706C6553656C656374696F6E48616E646C65723A2066756E6374696F6E2870436865636B626F78242C20704576656E74297B0A090909766172200A0909090973';
wwv_flow_api.g_varchar2_table(135) := '656C6620203D20746869732C0A0909090976616C7565203D2070436865636B626F78242E61747472282776616C756527292C0A09090909657874726156616C756573203D2022223B0A09090964656275672E6D6573736167652873656C662E435F4C4F47';
wwv_flow_api.g_varchar2_table(136) := '5F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20274D756C7469706C652073656C656374696F6E2068616E646C657220747269676765726564206279206576656E743A20272C20704576656E74293B0A0A0909097043686563';
wwv_flow_api.g_varchar2_table(137) := '6B626F78242E656163682866756E6374696F6E2829207B0A09090909242E6561636828746869732E617474726962757465732C2066756E6374696F6E2829207B0A09090909092F2F20746869732E61747472696275746573206973206E6F74206120706C';
wwv_flow_api.g_varchar2_table(138) := '61696E206F626A6563742C2062757420616E2061727261790A09090909092F2F206F6620617474726962757465206E6F6465732C20776869636820636F6E7461696E20626F746820746865206E616D6520616E642076616C75650A090909090969662874';
wwv_flow_api.g_varchar2_table(139) := '6869732E73706563696669656429207B0A090909090909696628747970656F662073656C662E73746F7261676550726F706572746965732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E73203D3D3D2027737472696E6727297B0A09';
wwv_flow_api.g_varchar2_table(140) := '090909090909636F6E737420636F6C756D6E734944203D2073656C662E73746F7261676550726F706572746965732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E732E746F4C6F7765724361736528292E73706C697428273A27293B';
wwv_flow_api.g_varchar2_table(141) := '0A090909090909096966202820242E696E417272617928746869732E6E616D652E746F4C6F7765724361736528292C20636F6C756D6E7349442920213D3D202D312029207B0A0909090909090909657874726156616C756573202B3D20746869732E7661';
wwv_flow_api.g_varchar2_table(142) := '6C7565202B20273A270A090909090909097D0A0909090909097D0A09090909097D0A090909097D293B0A0909097D293B0A0A0909096966202873656C662E73656C656374656456616C7565732E696E636C756465732876616C75652929207B0A09090909';
wwv_flow_api.g_varchar2_table(143) := '73656C662E5F72656D6F766546726F6D53656C656374656456616C7565732876616C7565293B0A0909097D20656C7365207B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F';
wwv_flow_api.g_varchar2_table(144) := '475F5052454649582C2027657874726156616C75657320636865636B206265666F7265207075736820746F206164643A20272C20657874726156616C756573293B0A0909090973656C662E5F616464546F53656C656374656456616C7565732876616C75';
wwv_flow_api.g_varchar2_table(145) := '652C20657874726156616C756573293B0A0909097D2020202020200A09090973656C662E5F6170706C7953656C656374696F6E28293B0A09090973656C662E5F73746F726556616C75657328293B200A09097D2C20200A0A09095F73656C656374416C6C';
wwv_flow_api.g_varchar2_table(146) := '48616E646C65723A2066756E6374696F6E28704576656E74297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F505245';
wwv_flow_api.g_varchar2_table(147) := '4649582C202753656C65637420616C6C2068616E646C657220747269676765726564206279206576656E743A20272C20704576656E74293B20200A0A0909092F2F2050617274206F6620636F646520666F7220637573746F6D20636865636B626F782073';
wwv_flow_api.g_varchar2_table(148) := '74796C65206F6E6C790A0909096966202873656C662E73656C656374696F6E50726F706572746965732E637573746F6D436865636B626F785374796C6529207B0A090909090A090909096966202873656C662E686561646572436865636B626F78242E68';
wwv_flow_api.g_varchar2_table(149) := '6173436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E29297B0A09090909092F2F20696620636865636B626F7820697320656D707479202D3E207468656E2073656C656374206974';
wwv_flow_api.g_varchar2_table(150) := '20616E6420616C6C2076697369626C650A090909090973656C662E686561646572436865636B626F78240A0909090909092E72656D6F7665436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F78';
wwv_flow_api.g_varchar2_table(151) := '49636F6E290A0909090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E293B0A090909090973656C662E63656C6C436865636B626F786573242E65616368';
wwv_flow_api.g_varchar2_table(152) := '2866756E6374696F6E28297B0A0909090909096C6574200A09090909090909636865636B626F7824203D20242874686973292C0A0909090909090976616C7565202020203D20636865636B626F78242E61747472282776616C756527293B0A0909090909';
wwv_flow_api.g_varchar2_table(153) := '0973656C662E5F616464546F53656C656374656456616C7565732876616C7565293B0A09090909097D293B0A0A090909097D20656C7365207B0A09090909092F2F20696620636865636B626F7820697320636865636B6564207468656E20636C65617220';
wwv_flow_api.g_varchar2_table(154) := '697420616E6420616C6C2076697369626C65200A090909090973656C662E686561646572436865636B626F78240A0909090909092E72656D6F7665436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C65637465644368';
wwv_flow_api.g_varchar2_table(155) := '65636B626F7849636F6E290A0909090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E293B0A090909090973656C662E63656C6C436865636B626F786573242E65';
wwv_flow_api.g_varchar2_table(156) := '6163682866756E6374696F6E28297B0A0909090909096C6574200A09090909090909636865636B626F7824203D20242874686973292C0A0909090909090976616C7565202020203D20636865636B626F78242E61747472282776616C756527293B0A0909';
wwv_flow_api.g_varchar2_table(157) := '0909090973656C662E5F72656D6F766546726F6D53656C656374656456616C7565732876616C7565293B0A09090909097D293B090A090909097D0A0A0909092F2F2050617274206F6620636F646520666F72207374616E646172642048544D4C20636865';
wwv_flow_api.g_varchar2_table(158) := '636B626F780A0909097D20656C7365207B0A090909092F2F20696620636C69636B20776173206E6F7420696E2074686520636865636B626F782C206265636175736520636865636B626F782077696C6C20636865636B20697473656C660A090909096966';
wwv_flow_api.g_varchar2_table(159) := '2028212428704576656E742E746172676574292E69732873656C662E686561646572436865636B626F78242929207B0A090909090973656C662E686561646572436865636B626F78242E70726F702827636865636B6564272C202173656C662E68656164';
wwv_flow_api.g_varchar2_table(160) := '6572436865636B626F78242E70726F702827636865636B65642729293B0A090909097D0A090909096966202873656C662E686561646572436865636B626F78242E70726F702827636865636B65642729297B0A09090909092F2F2073656C65637420616C';
wwv_flow_api.g_varchar2_table(161) := '6C2076697369626C650A090909090973656C662E63656C6C436865636B626F786573242E656163682866756E6374696F6E28297B0A0909090909096C6574200A09090909090909636865636B626F7824203D20242874686973292C0A0909090909090976';
wwv_flow_api.g_varchar2_table(162) := '616C7565202020203D20636865636B626F78242E61747472282776616C756527292C0A09090909090909657874726156616C7565733B0A0A090909090909636865636B626F78242E656163682866756E6374696F6E2829207B0A09090909090909242E65';
wwv_flow_api.g_varchar2_table(163) := '61636828746869732E617474726962757465732C2066756E6374696F6E2829207B0A09090909090909092F2F20746869732E61747472696275746573206973206E6F74206120706C61696E206F626A6563742C2062757420616E2061727261790A090909';
wwv_flow_api.g_varchar2_table(164) := '09090909092F2F206F6620617474726962757465206E6F6465732C20776869636820636F6E7461696E20626F746820746865206E616D6520616E642076616C75650A0909090909090909696628746869732E73706563696669656429207B0A0909090909';
wwv_flow_api.g_varchar2_table(165) := '09090909696628747970656F662073656C662E73746F7261676550726F706572746965732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E73203D3D3D2027737472696E6727297B0A09090909090909090909636F6E737420636F6C75';
wwv_flow_api.g_varchar2_table(166) := '6D6E734944203D2073656C662E73746F7261676550726F706572746965732E6164646974696F6E616C436F6C6C656374696F6E436F6C756D6E732E746F4C6F7765724361736528292E73706C697428273A27293B0A090909090909090909096966202820';
wwv_flow_api.g_varchar2_table(167) := '242E696E417272617928746869732E6E616D652E746F4C6F7765724361736528292C20636F6C756D6E7349442920213D3D202D312029207B0A0909090909090909090909657874726156616C756573202B3D20746869732E76616C7565202B20273A270A';
wwv_flow_api.g_varchar2_table(168) := '090909090909090909097D0A0909090909090909097D090909090920200A09090909090909097D0A090909090909097D293B0A0909090909097D293B0A0A09090909090973656C662E5F616464546F53656C656374656456616C7565732876616C75652C';
wwv_flow_api.g_varchar2_table(169) := '20657874726156616C756573293B0A09090909097D293B0A090909097D20656C7365207B0A09090909092F2F20636C65617220616C6C2076697369626C650A090909090973656C662E63656C6C436865636B626F786573242E656163682866756E637469';
wwv_flow_api.g_varchar2_table(170) := '6F6E28297B0A0909090909096C6574200A09090909090909636865636B626F7824203D20242874686973292C0A0909090909090976616C7565202020203D20636865636B626F78242E61747472282776616C756527293B0A09090909090973656C662E5F';
wwv_flow_api.g_varchar2_table(171) := '72656D6F766546726F6D53656C656374656456616C7565732876616C7565293B0A09090909097D293B0A090909097D0A0909097D0A0A09090973656C662E5F6170706C7953656C656374696F6E28293B200A09090973656C662E5F73746F726556616C75';
wwv_flow_api.g_varchar2_table(172) := '657328293B0A0909090A09097D2C0A0A09095F6170706C7953656C656374696F6E3A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F36';
wwv_flow_api.g_varchar2_table(173) := '2C2073656C662E435F4C4F475F5052454649582C20274170706C79696E672076697375616C207374796C6520746F2073656C656374656420726F77732E2E2E27293B20202020200A0A0909092F2F20636C65617220616C6C206362780A09090969662028';
wwv_flow_api.g_varchar2_table(174) := '73656C662E73656C656374696F6E50726F706572746965732E637573746F6D436865636B626F785374796C65297B0A0909090973656C662E63656C6C436865636B626F786573240A09090909092E72656D6F7665436C6173732873656C662E73656C6563';
wwv_flow_api.g_varchar2_table(175) := '74696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E290A09090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E293B0A090909';
wwv_flow_api.g_varchar2_table(176) := '0973656C662E686561646572436865636B626F78240A09090909092E72656D6F7665436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E290A09090909092E616464436C6173';
wwv_flow_api.g_varchar2_table(177) := '732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E293B0A0909097D20656C7365207B0A0909090973656C662E63656C6C436865636B626F786573242E70726F702827636865636B6564272C20';
wwv_flow_api.g_varchar2_table(178) := '66616C7365293B0A0909090973656C662E686561646572436865636B626F78242E70726F702827636865636B6564272C2066616C7365293B0A0909097D0A0909092F2F2072656D6F76652073656C656374656420726F77207374796C65730A0909097365';
wwv_flow_api.g_varchar2_table(179) := '6C662E63656C6C436865636B626F786573242E636C6F736573742827747227292E72656D6F7665436C6173732873656C662E435F53454C45435445445F524F575F434C415353293B0A0A0909092F2F2073656C65637420636865636B626F786573206163';
wwv_flow_api.g_varchar2_table(180) := '636F7264696E6720746F2073656C65637465642076616C7565732061727261790A0909092F2F20616464207374796C6520746F2073656C656374656420726F77730A09090973656C662E63656C6C436865636B626F786573242E656163682866756E6374';
wwv_flow_api.g_varchar2_table(181) := '696F6E28297B0A090909096C6574200A0909090909636865636B626F7824203D20242874686973292C0A090909090976616C756520202020203D20636865636B626F78242E61747472282776616C756527292C0A0909090909726F77242020202020203D';
wwv_flow_api.g_varchar2_table(182) := '20636865636B626F78242E636C6F736573742827747227293B0A090909096966202873656C662E73656C656374656456616C7565732E696E636C756465732876616C756529297B0A09090909096966202873656C662E73656C656374696F6E50726F7065';
wwv_flow_api.g_varchar2_table(183) := '72746965732E637573746F6D436865636B626F785374796C65297B0A090909090909636865636B626F78240A090909090909092E72656D6F7665436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B62';
wwv_flow_api.g_varchar2_table(184) := '6F7849636F6E290A090909090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E293B0A09090909097D20656C7365207B0A090909090909636865636B626F';
wwv_flow_api.g_varchar2_table(185) := '78242E70726F702827636865636B6564272C2074727565293B0A09090909097D0A09090909090A0909090909726F77242E616464436C6173732873656C662E435F53454C45435445445F524F575F434C415353293B0A090909097D200A0909097D293B0A';
wwv_flow_api.g_varchar2_table(186) := '0A0909092F2F20636865636B2069662068656164657220636865636B626F782073686F756C6420626520636865636B65640A0909096966202873656C662E73656C656374696F6E50726F706572746965732E637573746F6D436865636B626F785374796C';
wwv_flow_api.g_varchar2_table(187) := '65297B200A090909096966202873656C662E63656C6C436865636B626F786573242E6C656E677468203D3D3D2073656C662E63656C6C436865636B626F786573242E66696C74657228272E272B73656C662E73656C656374696F6E50726F706572746965';
wwv_flow_api.g_varchar2_table(188) := '732E73656C6563746564436865636B626F7849636F6E292E6C656E677468297B0A090909090973656C662E686561646572436865636B626F78240A0909090909092E72656D6F7665436C6173732873656C662E73656C656374696F6E50726F7065727469';
wwv_flow_api.g_varchar2_table(189) := '65732E656D707479436865636B626F7849636F6E290A0909090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E293B0A090909097D0A0909097D20656C73';
wwv_flow_api.g_varchar2_table(190) := '65207B0A090909096966202873656C662E63656C6C436865636B626F786573242E6C656E677468203D3D3D2073656C662E63656C6C436865636B626F786573242E66696C74657228273A636865636B656427292E6C656E677468297B0A09090909097365';
wwv_flow_api.g_varchar2_table(191) := '6C662E686561646572436865636B626F78242E70726F702827636865636B6564272C2074727565293B0A090909097D0A0909097D0A0A0A09097D2C20200A09200A09095F616464546F53656C656374656456616C7565733A2066756E6374696F6E287056';
wwv_flow_api.g_varchar2_table(192) := '616C75652C2070457874726156616C756573297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027';
wwv_flow_api.g_varchar2_table(193) := '416464696E672076616C756520746F2063757272656E746C792073656C656374656420726F77733A20272C207056616C7565293B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C';
wwv_flow_api.g_varchar2_table(194) := '4F475F5052454649582C2027416464696E6720657874726156616C756520746F2063757272656E746C792073656C656374656420726F77733A20272C2070457874726156616C756573293B0A0909090A090909696620282173656C662E73656C65637465';
wwv_flow_api.g_varchar2_table(195) := '6456616C7565732E696E636C75646573287056616C756529297B0A0909090973656C662E73656C656374656456616C7565732E70757368287056616C7565293B0A0909097D0A09090973656C662E657874726156616C7565732E70757368287045787472';
wwv_flow_api.g_varchar2_table(196) := '6156616C756573293B0A09097D2C0A09095F72656D6F766546726F6D53656C656374656456616C7565733A2066756E6374696F6E287056616C7565297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873';
wwv_flow_api.g_varchar2_table(197) := '656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202752656D6F76696E672076616C75652066726F6D2063757272656E746C792073656C656374656420726F77733A20272C207056616C7565293B0A0A09';
wwv_flow_api.g_varchar2_table(198) := '090973656C662E73656C656374656456616C7565732E73706C6963652873656C662E73656C656374656456616C7565732E696E6465784F66287056616C7565292C2031293B0A09090973656C662E657874726156616C7565732E73706C6963652873656C';
wwv_flow_api.g_varchar2_table(199) := '662E657874726156616C7565732E696E6465784F66287056616C7565292C2031293B0A09097D2C20202020202020200A09095F636C65617253656C656374656456616C7565733A2066756E6374696F6E28297B0A0909097661722073656C66203D207468';
wwv_flow_api.g_varchar2_table(200) := '69733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027436C656172696E672073656C65637465642076616C7565732E2E2E27293B0A0A0909097365';
wwv_flow_api.g_varchar2_table(201) := '6C662E73656C656374656456616C756573203D205B5D3B0A09090973656C662E657874726156616C756573203D205B5D3B0A09097D2C202020200A0A09095F67657453746F72656456616C7565733A2066756E6374696F6E28297B0A0909097661722073';
wwv_flow_api.g_varchar2_table(202) := '656C66203D20746869733B0A09090973656C662E73656C656374656456616C756573203D20205B5D3B202F2F20696E697469616C697A6520656D7074792061727261790A09090973656C662E657874726156616C756573203D20205B5D3B202F2F20696E';
wwv_flow_api.g_varchar2_table(203) := '697469616C697A6520656D7074792061727261790A0909090A0909092F2F2069662073656C656374696F6E2069732073746F72656420696E20636F6C6C656374696F6E207468656E2074727920746F20726561642069740A0909096966202873656C662E';
wwv_flow_api.g_varchar2_table(204) := '73746F7261676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E297B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F505245';
wwv_flow_api.g_varchar2_table(205) := '4649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820636F6C6C656374696F6E2E2E2E27293B0A090909096C65740A0909090909616A617844617461203D207B0A09090909090922783031223A202247';
wwv_flow_api.g_varchar2_table(206) := '4554222C0A09090909090922783033223A2073656C662E73746F7261676550726F706572746965732E73746F72616765436F6C6C656374696F6E4E616D650A09090909097D2C0A0909090909616A61784F7074696F6E73203D207B0A0909090909092273';
wwv_flow_api.g_varchar2_table(207) := '756363657373222020202020202020202020202020202020203A20242E70726F78792873656C662E5F67657453746F72656456616C756573416A6178737563636573732C2020202073656C66292C0A090909090909226572726F72222020202020202020';
wwv_flow_api.g_varchar2_table(208) := '2020202020202020202020203A20242E70726F78792873656C662E5F67657453746F72656456616C756573416A61786572726F722C20202020202073656C66292C0A0909090909092274617267657422202020202020202020202020202020202020203A';
wwv_flow_api.g_varchar2_table(209) := '202723272B73656C662E7265706F727450726F706572746965732E726567696F6E49642C0A090909090909226C6F6164696E67496E64696361746F72222020202020202020203A202723272B73656C662E7265706F727450726F706572746965732E7265';
wwv_flow_api.g_varchar2_table(210) := '67696F6E49642C0A090909090909226C6F6164696E67496E64696361746F72506F736974696F6E22203A202263656E7465726564220A09090909097D3B200A09090909090A09090909617065782E7365727665722E706C7567696E20282073656C662E6F';
wwv_flow_api.g_varchar2_table(211) := '7074696F6E732E616A61784964656E7469666965722C20616A6178446174612C20616A61784F7074696F6E7320293B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F50';
wwv_flow_api.g_varchar2_table(212) := '52454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820636F6C6C656374696F6E2E2E2E272C2027416A61782073656E7427293B20200A0909097D0A0909092F2F2069662073656C656374696F6E20';
wwv_flow_api.g_varchar2_table(213) := '6973206E6F742073746F72656420696E20636F6C6C656374696F6E2C206275742069732073746F72656420696E2061706578206974656D207468656E20726561642069740A0909092F2F20616E64206170706C7920746F207265706F72740A090909656C';
wwv_flow_api.g_varchar2_table(214) := '7365206966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D2026262024762873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D652920213D2022';
wwv_flow_api.g_varchar2_table(215) := '22297B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820';
wwv_flow_api.g_varchar2_table(216) := '4974656D2E2E2E27293B0A0909090973656C662E73656C656374656456616C756573203D2024762873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D65292E73706C69742873656C662E73746F726167655072';
wwv_flow_api.g_varchar2_table(217) := '6F706572746965732E76616C7565536570617261746F72293B0A0909090973656C662E5F6170706C7953656C656374696F6E28293B0A0909097D200A09097D2C0A09095F67657453746F72656456616C756573416A6178737563636573733A2066756E63';
wwv_flow_api.g_varchar2_table(218) := '74696F6E2870446174612C2070546578745374617475732C20704A71584852297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F';
wwv_flow_api.g_varchar2_table(219) := '4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820636F6C6C656374696F6E2E2E2E272C2027416A61782073756363657373272C2070446174612C2070546578745374617475732C';
wwv_flow_api.g_varchar2_table(220) := '20704A71584852293B0A0A09090973656C662E73656C656374656456616C756573203D2070446174612E73656C656374656456616C7565732E6D6170286F626A203D3E206F626A2E636865636B626F785F76616C7565293B0A09090973656C662E657874';
wwv_flow_api.g_varchar2_table(221) := '726156616C756573203D2070446174612E73656C656374656456616C7565732E6D6170286F626A203D3E206F626A2E65787472615F76616C756573293B0A09090973656C662E5F6170706C7953656C656374696F6E28293B0A09097D2C0A09095F676574';
wwv_flow_api.g_varchar2_table(222) := '53746F72656456616C756573416A61786572726F723A2066756E6374696F6E28704A715848522C2070546578745374617475732C20704572726F725468726F776E297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573';
wwv_flow_api.g_varchar2_table(223) := '736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820636F6C6C656374696F6E2E2E2E272C2027';
wwv_flow_api.g_varchar2_table(224) := '416A6178206572726F72272C20704A715848522C2070546578745374617475732C20704572726F725468726F776E20293B0A0A0909092F2F2069662076616C75652063616E206265206F627461696E65642066726F6D2061706578206974656D20746865';
wwv_flow_api.g_varchar2_table(225) := '6E2074727920746F20646F2069740A0909096966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D20297B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C';
wwv_flow_api.g_varchar2_table(226) := '5F44454255472C2073656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D2041504558204974656D2E2E2E27293B0A0909090973656C662E73656C656374656456616C756573203D';
wwv_flow_api.g_varchar2_table(227) := '2024762873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D65292E73706C69742873656C662E73746F7261676550726F706572746965732E76616C7565536570617261746F72293B0A0909090973656C662E5F';
wwv_flow_api.g_varchar2_table(228) := '6170706C7953656C656374696F6E28293B0A0909097D200A09090973656C662E5F7468726F774572726F7228275F67657453746F72656456616C756573416A61786572726F72272C2073656C662E435F4552524F525F414A41585F524541445F4641494C';
wwv_flow_api.g_varchar2_table(229) := '5552452C2066616C7365293B0A09097D2C0A0A090A09095F73746F726556616C7565733A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A0A0909092F2F2073746F72696E672073656C65637465642076616C75657320';
wwv_flow_api.g_varchar2_table(230) := '696E2061706578206974656D200A0909096966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D297B202020200A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C';
wwv_flow_api.g_varchar2_table(231) := '564C5F362C2073656C662E435F4C4F475F5052454649582C202753746F72696E672073656C65637465642076616C75657320696E2041504558206974656D2E2E2E27293B0A090909092F2F2069662073656C656374696F6E2063616E6E6F742065786365';
wwv_flow_api.g_varchar2_table(232) := '6564206D6178696D756D206C656E67746820696E206279746573207468656E0A090909092F2F2072656D6F7665206C6173742073656C65637465642076616C75657320756E74696C6C20697420666974730A090909096966202873656C662E73746F7261';
wwv_flow_api.g_varchar2_table(233) := '676550726F706572746965732E6C696D697453656C656374696F6E203D3D3D2027592720297B0A09090909096C6574200A090909090909656E636F646572203D206E65772054657874456E636F64657228292C0A09090909090973656C656374696F6E45';
wwv_flow_api.g_varchar2_table(234) := '786365646564203D2066616C73653B0A09090909097768696C65202820656E636F6465722E656E636F6465282073656C662E73656C656374656456616C7565732E6A6F696E2873656C662E73746F7261676550726F706572746965732E76616C75655365';
wwv_flow_api.g_varchar2_table(235) := '70617261746F722920292E6C656E677468203E2073656C662E435F53544F524147455F4954454D5F4D41585F42595445535F434F554E5420297B0A09090909090973656C662E73656C656374656456616C7565732E706F7028293B0A0909090909097365';
wwv_flow_api.g_varchar2_table(236) := '6C656374696F6E45786365646564203D20747275653B0A09090909097D0A09090909096966202873656C656374696F6E45786365646564297B0A09090909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C66';
wwv_flow_api.g_varchar2_table(237) := '2E435F4C4F475F5052454649582C20274C696D6974696E672073656C656374696F6E206C656E67746820746F206D6178696D756D206E756D626572206F6620627974657320272C2073656C662E435F53544F524147455F4954454D5F4D41585F42595445';
wwv_flow_api.g_varchar2_table(238) := '535F434F554E54293B0A090909090909617065782E6576656E742E747269676765722873656C662E726567696F6E242C2073656C662E435F4556454E545F4D41585F53454C454354494F4E5F45584345444544293B0A09090909090973656C662E5F6170';
wwv_flow_api.g_varchar2_table(239) := '706C7953656C656374696F6E28293B0A09090909097D202020202020202020200A090909090924732873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D652C2073656C662E73656C656374656456616C756573';
wwv_flow_api.g_varchar2_table(240) := '2E6A6F696E2873656C662E73746F7261676550726F706572746965732E76616C7565536570617261746F722920293B0A090909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F50524546';
wwv_flow_api.g_varchar2_table(241) := '49582C202753656C65637465642076616C7565732073746F72656420696E2041504558206974656D207375636365737366756C6C7927293B0A090909097D200A090909090A090909092F2F2069662073656C6C656374696F6E206973206E6F74206C696D';
wwv_flow_api.g_varchar2_table(242) := '69746564207468656E20777269746520697420746F207468652061706578206974656D0A09090909656C7365207B0A090909090924732873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D652C2073656C662E';
wwv_flow_api.g_varchar2_table(243) := '73656C656374656456616C7565732E6A6F696E2873656C662E73746F7261676550726F706572746965732E76616C7565536570617261746F722920293B0A090909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073';
wwv_flow_api.g_varchar2_table(244) := '656C662E435F4C4F475F5052454649582C202753656C65637465642076616C7565732073746F72656420696E2041504558206974656D207375636365737366756C6C7927293B0A090909097D20202020202020200A0909097D0A0A0909092F2F2073746F';
wwv_flow_api.g_varchar2_table(245) := '72696E672073656C65637465642076616C75657320696E206170657820636F6C6C656374696F6E0A0909096966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E207C7C2073';
wwv_flow_api.g_varchar2_table(246) := '656C662E73746F7261676550726F706572746965732E6974656D4175746F5375626D6974297B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202753';
wwv_flow_api.g_varchar2_table(247) := '6176696E672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E2E2E27293B0A090909096C65740A0909090909616A617844617461203D207B0A090909090909';
wwv_flow_api.g_varchar2_table(248) := '22783031223A2073656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E203F202253455422203A20225355424D4954222C0A09090909090922783032223A2073656C662E73746F726167';
wwv_flow_api.g_varchar2_table(249) := '6550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E2C0A09090909090922783033223A2073656C662E73746F7261676550726F706572746965732E73746F72616765436F6C6C656374696F6E4E616D652C0A0909';
wwv_flow_api.g_varchar2_table(250) := '0909090922663031223A2073656C662E73656C656374656456616C7565732C0A09090909090922663032223A2073656C662E657874726156616C7565730A09090909097D2C0A0909090909616A61784F7074696F6E73203D207B0A090909090909227375';
wwv_flow_api.g_varchar2_table(251) := '636365737322202020203A20242E70726F78792873656C662E5F73746F726556616C756573416A6178737563636573732C2020202073656C66292C0A090909090909226572726F72222020202020203A20242E70726F78792873656C662E5F73746F7265';
wwv_flow_api.g_varchar2_table(252) := '56616C756573416A61786572726F722C20202020202073656C66290A09090909097D3B200A090909096966202873656C662E73746F7261676550726F706572746965732E6974656D4175746F5375626D6974297B0A0909090909616A6178446174612E70';
wwv_flow_api.g_varchar2_table(253) := '6167654974656D73203D205B73656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D655D3B0A090909097D0A09090909617065782E7365727665722E706C7567696E20282073656C662E6F7074696F6E732E616A61';
wwv_flow_api.g_varchar2_table(254) := '784964656E7469666965722C20616A6178446174612C20616A61784F7074696F6E7320293B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20275361';
wwv_flow_api.g_varchar2_table(255) := '76696E672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E2E2E272C2027416A61782073656E7427293B200A0909097D0A09097D2C202020200A0A09095F73';
wwv_flow_api.g_varchar2_table(256) := '746F726556616C756573416A6178737563636573733A2066756E6374696F6E2870446174612C2070546578745374617475732C20704A71584852297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D657373616765287365';
wwv_flow_api.g_varchar2_table(257) := '6C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027536176696E672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F';
wwv_flow_api.g_varchar2_table(258) := '6E292E2E2E272C2027416A61782073756363657373272C2070446174612C2070546578745374617475732C20704A71584852293B0A09097D2C0A09095F73746F726556616C756573416A61786572726F723A2066756E6374696F6E28704A715848522C20';
wwv_flow_api.g_varchar2_table(259) := '70546578745374617475732C20704572726F725468726F776E297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052';
wwv_flow_api.g_varchar2_table(260) := '454649582C2027536176696E672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E2E2E272C2027416A6178206572726F72272C20704A715848522C20705465';
wwv_flow_api.g_varchar2_table(261) := '78745374617475732C20704572726F725468726F776E20293B0A0A09090973656C662E5F7468726F774572726F7228275F73746F726556616C756573416A61786572726F72272C2073656C662E435F4552524F525F414A41585F53544F52455F4641494C';
wwv_flow_api.g_varchar2_table(262) := '5552452C2066616C7365293B0A09097D2C0A0A09095F7468726F774572726F723A2066756E6374696F6E287046756E6374696F6E4E616D652C20704572726F724D6573736167652C207053746F70506C7567696E2C2070446973706C6179506167654572';
wwv_flow_api.g_varchar2_table(263) := '726F724D65737361676573297B0A090909766172200A0909090973656C66203D20746869732C0A09090909646973706C6179506167654572726F724D65737361676573203D2070446973706C6179506167654572726F724D65737361676573207C7C2073';
wwv_flow_api.g_varchar2_table(264) := '656C662E435F444953504C41595F504147455F4552524F525F4D455353414745532C0A09090909656E64557365724572726F724D657373616765203D2073656C662E435F454E445F555345525F4552524F525F505245464958202B20704572726F724D65';
wwv_flow_api.g_varchar2_table(265) := '7373616765202B2073656C662E435F454E445F555345525F4552524F525F5355464649583B0A0909090A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F4552524F522C2073656C662E435F4C4F475F5052454649582C20';
wwv_flow_api.g_varchar2_table(266) := '7046756E6374696F6E4E616D652C20704572726F724D657373616765293B0A0909090A09090969662028646973706C6179506167654572726F724D65737361676573297B0A09090909617065782E6D6573736167652E636C6561724572726F727328293B';
wwv_flow_api.g_varchar2_table(267) := '0A09090909617065782E6D6573736167652E73686F774572726F7273287B0A0909090909747970653A20202020202020226572726F72222C0A09090909096C6F636174696F6E3A2020202270616765222C0A09090909096D6573736167653A2020202065';
wwv_flow_api.g_varchar2_table(268) := '6E64557365724572726F724D6573736167652C0A0909090909756E736166653A202020202066616C73650A090909097D293B0A0909097D0A090909696620287053746F70506C7567696E297B0A090909097468726F77206E6577204572726F7228656E64';
wwv_flow_api.g_varchar2_table(269) := '557365724572726F724D657373616765293B0A0909097D0A09097D2C0A0A092F2F206A517565727920776964676574207075626C6963206D6574686F6473200A0A09636C65617253656C656374696F6E3A2066756E6374696F6E28297B0A090976617220';
wwv_flow_api.g_varchar2_table(270) := '73656C66203D20746869733B0A090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027436C6561722073656C656374696F6E207075626C6963206D6574686F64';
wwv_flow_api.g_varchar2_table(271) := '20696E766F6B65642E2E2E27293B200A09090A090973656C662E5F636C65617253656C656374656456616C75657328293B0A090973656C662E5F6170706C7953656C656374696F6E28293B0A090973656C662E5F73746F726556616C75657328293B0A09';
wwv_flow_api.g_varchar2_table(272) := '7D2C0A092F2F206A517565727920776964676574206E6174697665206D6574686F64730A095F64657374726F793A2066756E6374696F6E28297B0A097D2C0A0A092F2F206F7074696F6E733A2066756E6374696F6E2820704F7074696F6E7320297B0A09';
wwv_flow_api.g_varchar2_table(273) := '2F2F202020746869732E5F73757065722820704F7074696F6E7320293B0A092F2F207D2C0A095F7365744F7074696F6E3A2066756E6374696F6E2820704B65792C207056616C75652029207B0A09096966202820704B6579203D3D3D202276616C756522';
wwv_flow_api.g_varchar2_table(274) := '2029207B0A0909097056616C7565203D20746869732E5F636F6E73747261696E28207056616C756520293B0A09097D0A0909746869732E5F73757065722820704B65792C207056616C756520293B0A097D2C20200A095F7365744F7074696F6E733A2066';
wwv_flow_api.g_varchar2_table(275) := '756E6374696F6E2820704F7074696F6E732029207B0A0909746869732E5F73757065722820704F7074696F6E7320293B0A097D2C202020200A090A097D293B0A207D2928617065782E64656275672C20617065782E6A517565727920293B0A0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(94264058921844785)
,p_plugin_id=>wwv_flow_api.id(98201821780201218)
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
