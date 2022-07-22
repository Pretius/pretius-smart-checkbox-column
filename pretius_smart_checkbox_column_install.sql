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
 p_id=>wwv_flow_api.id(66241640733046753)
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
'',
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
'	v_ajax_command     varchar2(30)  DEFAULT APEX_APPLICATION.G_X01;',
'	v_save_to_coll     varchar2(30)  DEFAULT APEX_APPLICATION.G_X02;',
'	v_collection_name  varchar2(255) DEFAULT upper(APEX_APPLICATION.G_X03);',
'	v_collection_query varchar2(4000);',
'	v_ref_cur          sys_refcursor;',
'	v_result           apex_plugin.t_dynamic_action_ajax_result;',
'BEGIN',
'',
'	--debug',
'	IF apex_application.g_debug THEN',
'		apex_plugin_util.debug_dynamic_action ( ',
'			p_plugin         => p_plugin,',
'			p_dynamic_action => p_dynamic_action',
'		);',
'	END IF;',
'',
'	CASE upper(v_ajax_command)',
'		WHEN ''GET'' THEN',
'			open v_ref_cur for ',
'				SELECT ',
'					C001 as "checkbox_value"',
'				FROM',
'					APEX_COLLECTIONS ',
'				WHERE ',
'					COLLECTION_NAME = v_collection_name;',
'',
'			apex_json.open_object;      ',
'				apex_json.write(''selectedValues'', v_ref_cur);',
'				apex_json.write(''status'', ''Ok'');',
'				apex_json.write(''message'', ''Ok'');      ',
'			apex_json.close_object;',
'			--close v_ref_cur;',
'',
'		WHEN ''SET'' THEN',
'			IF upper(v_save_to_coll) = ''TRUE'' THEN ',
'				APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION( v_collection_name );    ',
'				APEX_COLLECTION.ADD_MEMBERS(',
'					p_collection_name => v_collection_name,',
'					p_c001            => v_selected_values',
'				);',
'			END IF;    ',
'',
'			apex_json.open_object;      ',
'				apex_json.write(''status'', ''Ok'');',
'				apex_json.write(''message'', ''APEX Collection updated successfully.'');      ',
'			apex_json.close_object;',
'',
'		WHEN ''SUBMIT'' THEN ',
'			apex_json.open_object;      ',
'				apex_json.write(''status'', ''Ok'');',
'				apex_json.write(''message'', ''APEX Item submitted successfully.'');      ',
'			apex_json.close_object;',
'		ELSE ',
'			apex_json.open_object;      ',
'				apex_json.write(''status'', ''Ok'');',
'				apex_json.write(''message'', ''No command for AJAX Callback.'');      ',
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
,p_version_identifier=>'1.1.0'
,p_about_url=>'https://github.com/Pretius/pretius-smart-checkbox-column'
,p_files_version=>5
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(66251633783062128)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
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
 p_id=>wwv_flow_api.id(66261623043064165)
,p_plugin_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_display_sequence=>10
,p_display_value=>'Store selected values in APEX Item'
,p_return_value=>'STORE_IN_ITEM'
,p_help_text=>'Checking this attribute will cause all selected values to be stored in APEX Item. Item needs to be provided in separate attribute ("APEX Item to store selected values").'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(66271643203065383)
,p_plugin_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_display_sequence=>20
,p_display_value=>'Store selected values in APEX Collection'
,p_return_value=>'STORE_IN_COLLECTION'
,p_help_text=>'Checking this attribute will cause all selected values to be stored in APEX collection. Collection name can be defined in separate attribute ("APEX Collection name to store selected values"). Default collection name is PX_SELECTED_VALUES where X is a'
||'n application page number where the plugin instance exists. It is recommanded to change the defalut value, especially when there are more than one plugin instance existing on the same page.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(66281599729067273)
,p_plugin_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_display_sequence=>30
,p_display_value=>'Allow multiple selection'
,p_return_value=>'ALLOW_MULTIPLE'
,p_help_text=>'Check this attribute to allow for selecting mutliple rows at once. When this checkbox is left empty, only one row can be selected at the same time and checkbox in the header is disabled.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(66291614622068755)
,p_plugin_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_display_sequence=>40
,p_display_value=>'Select with click on row'
,p_return_value=>'SELECT_ON_ROW_CLICK'
,p_help_text=>'Check this attribute to allow for selecting checkboxes when clicked anywhere on a row.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(62260760846443441)
,p_plugin_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_display_sequence=>50
,p_display_value=>'Custom checkbox style'
,p_return_value=>'CUSTOM_CHECKBOX_STYLE'
,p_help_text=>'When checked plugin will render icons instead of standard HTML checkboxes.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(62510914152357454)
,p_plugin_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_display_sequence=>60
,p_display_value=>'IR Limit column width'
,p_return_value=>'IR_LIMIT_COL_WIDTH'
,p_help_text=>'Automatically adjust checkbox column width to avoid empty space. Applicable only to Interactive Report.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(66301609611076205)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
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
 p_id=>wwv_flow_api.id(66311674010080016)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'APEX Item to store selected values'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Application page item that will be used to store currently selected row(s). Selection is stored as text and values are separated with character defined in attribute "Value separator" (default ":"). </p>',
'<p>Because of maximum value length of APEX items, you may want Pretius Smart checkbox plugin to prevent from exceeding this limit. In this case make sure that "Limit selection length to 4000 Bytes" attribute is set to "Yes". </p>',
'<p> Use "Auto submit storage item" to automatically submit item value to APEX session state. </p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(66321588947082961)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'APEX Collection name to store selected values'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_COLLECTION'
,p_text_case=>'UPPER'
,p_help_text=>'Specify name of APEX collection that will be used to store currently selected row(s). Each selected row value is stored in separate collection member in varchar2 column "C001". Default collection name is PX_SELECTED_VALUES where X is an application p'
||'age number where the plugin instance exists. It is recommanded to change the defalut value, especially when there is more than one plugin instance existing on the same page.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(66321902152086047)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
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
,p_depending_on_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p> Separator for subsequent selected values when stored in APEX item. Default separator is ":". </p>',
'<p> Maximum length of separator is 5 characters. </p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(66331677191092231)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
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
 p_id=>wwv_flow_api.id(68721993943499833)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Limit selection length to 4000 Bytes'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_is_common=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>'Because of maximum value length of APEX items, you may want Pretius Smart checkbox plugin to prevent from exceeding this limit. In this case set this attribute is set to "Yes". When the limit is reached, all selected values above the limit will be tr'
||'uncated and plugin will trigger an event "Maximum selection length exceeded".'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(68881473925369152)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Auto submit storage item'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_is_common=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'STORE_IN_ITEM'
,p_help_text=>'Set this attribute to "Yes" to automatically submit item value to APEX session state anytime selection is changed.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(62280513992482980)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Empty checkbox icon'
,p_attribute_type=>'ICON'
,p_is_required=>true
,p_default_value=>'fa-square-o'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'CUSTOM_CHECKBOX_STYLE'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(62281064846486234)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Selected checkbox icon'
,p_attribute_type=>'ICON'
,p_is_required=>true
,p_default_value=>'fa-check-square-o'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(66251633783062128)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'CUSTOM_CHECKBOX_STYLE'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(68851482946266301)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
,p_name=>'max_selection_length_exceeded'
,p_display_name=>'Maximum selection length exceeded'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A2A20506C7567696E3A205072657469757320536D61727420436865636B626F7820436F6C756D6E0A2A2056657273696F6E3A20312E312E300A2A0A2A20417574686F723A204164616D204B6965727A6B6F77736B690A2A204D61696C3A20616B69';
wwv_flow_api.g_varchar2_table(2) := '65727A6B6F77736B6940707265746975732E636F6D0A2A20547769747465723A20615F6B6965727A6B6F77736B690A2A20426C6F673A200A2A0A2A20446570656E64733A0A2A20202020617065782F64656275672E6A730A2A0920617065782F6576656E';
wwv_flow_api.g_varchar2_table(3) := '742E6A730A2A204368616E6765733A0A2A09312E302E30202D20496E697469616C2052656C656173650A2A09312E312E30202D204E65772066756E6374696F6E616C6965746965732061646465640A2A0909092A20537570706F727420666F72206D756C';
wwv_flow_api.g_varchar2_table(4) := '7469706C6520706C7567696E20696E7374616E636573206F6E207468652073616D65207265706F72740A2A0909092A20437573746F6D20636865636B626F7865732076697375616C697A6174696F6E730A2A0909092A204175746F206C696D6974696E67';
wwv_flow_api.g_varchar2_table(5) := '20636865636B626F7820636F6C756D6E20776964746820666F7220496E746572616374697665205265706F72740A2A2F0A0A2866756E6374696F6E202864656275672C2024297B0A092275736520737472696374223B0A0A09242E776964676574282022';
wwv_flow_api.g_varchar2_table(6) := '707265746975732E736D617274436865636B626F78436F6C756D6E222C207B0A09092F2F20636F6E7374616E74730A0909435F504C5547494E5F4E414D452020202020203A20275072657469757320536D61727420636865636B626F7820636F6C756D6E';
wwv_flow_api.g_varchar2_table(7) := '272C0A0909435F4C4F475F505245464958202020202020203A2027536D61727420636865636B626F7820636F6C756D6E3A20272C0A0909435F4C4F475F4C564C5F4552524F52202020203A2064656275672E4C4F475F4C4556454C2E4552524F522C2020';
wwv_flow_api.g_varchar2_table(8) := '202020202020202F2F2076616C756520312028656E642D757365722920200A0909435F4C4F475F4C564C5F5741524E494E4720203A2064656275672E4C4F475F4C4556454C2E5741524E2C202020202020202020202F2F2076616C756520322028646576';
wwv_flow_api.g_varchar2_table(9) := '656C6F706572290A0909435F4C4F475F4C564C5F4445425547202020203A2064656275672E4C4F475F4C4556454C2E494E464F2C202020202020202020202F2F2076616C7565203420286465627567290A0909435F4C4F475F4C564C5F36202020202020';
wwv_flow_api.g_varchar2_table(10) := '20203A2064656275672E4C4F475F4C4556454C2E4150505F54524143452C20202020202F2F2076616C75652036200A0909435F4C4F475F4C564C5F3920202020202020203A2064656275672E4C4F475F4C4556454C2E454E47494E455F54524143452C20';
wwv_flow_api.g_varchar2_table(11) := '202F2F2076616C756520390A0A0909435F535550504F525445445F5245504F52545F545950455320202020202020203A205B27436C6173736963205265706F7274272C2027496E746572616374697665205265706F7274275D2C0A0909435F444953504C';
wwv_flow_api.g_varchar2_table(12) := '41595F504147455F4552524F525F4D455353414745532020203A20747275652C0A0909435F454E445F555345525F4552524F525F5052454649582020202020202020203A2027436865636B626F782066756E6374696F6E616C697479206572726F723A20';
wwv_flow_api.g_varchar2_table(13) := '272C0A0909435F454E445F555345525F4552524F525F5355464649582020202020202020203A2027436F6E7461637420796F75722061646D696E6973747261746F722E272C0A0909435F4552524F525F5245504F52545F4E4F545F535550504F52544544';
wwv_flow_api.g_varchar2_table(14) := '202020203A202743686F73656E20726567696F6E206973206E6F742061207265706F7274206F7220746865207265706F72742074797065206973206E6F7420737570706F727465642E20272C0A0909435F4552524F525F4E4F5F434F4C554D4E5F464F55';
wwv_flow_api.g_varchar2_table(15) := '4E442020202020202020203A20275265706F727420636F6C756D6E20746F20646973706C617920636865636B626F78657320646F6573206E6F742065786973742E20272C0A0909435F4552524F525F434845434B424F5845535F444F5F4E4F545F455849';
wwv_flow_api.g_varchar2_table(16) := '5354203A20274E6F20636865636B626F7865732065786973742E20272C0A0909435F4552524F525F4954454D5F444F45535F4E4F545F455849535420202020203A202741504558206974656D2063686F73656E20746F2073746F72652073656C65637465';
wwv_flow_api.g_varchar2_table(17) := '642076616C75657320646F6573206E6F742065786973742E20272C0A0909435F4552524F525F414A41585F53544F52455F4641494C5552452020202020203A202753746F72696E672063757272656E746C792073656C656374656420726F777320686173';
wwv_flow_api.g_varchar2_table(18) := '206661696C65642E20272C0A0909435F4552524F525F414A41585F524541445F4641494C555245202020202020203A202752656164696E672063757272656E746C792073656C656374656420726F777320686173206661696C65642E20272C0A0909435F';
wwv_flow_api.g_varchar2_table(19) := '53454C45435445445F524F575F434C4153532020202020202020202020203A2027707363632D73656C65637465642D726F77272C0A0909435F53544F524147455F4954454D5F4D41585F42595445535F434F554E5420203A20343030302C0A0909435F45';
wwv_flow_api.g_varchar2_table(20) := '56454E545F4D41585F53454C454354494F4E5F455843454445442020203A20276D61785F73656C656374696F6E5F6C656E6774685F6578636565646564272C0A0A09096F7074696F6E733A207B0A09097D2C0A0A0A09092F2F206372656174652066756E';
wwv_flow_api.g_varchar2_table(21) := '6374696F6E0A09095F6372656174653A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F50';
wwv_flow_api.g_varchar2_table(22) := '52454649582C20275374617274696E672077696467657420696E697469616C697A6174696F6E2E2E2E272C20276F7074696F6E733A20272C2073656C662E6F7074696F6E73293B0A09090973656C662E7265706F727450726F70657274696573203D207B';
wwv_flow_api.g_varchar2_table(23) := '0A0909090922726567696F6E4964220909093A2073656C662E6F7074696F6E732E726567696F6E49642C0A0909090922726567696F6E54656D706C6174652220093A2073656C662E6F7074696F6E732E726567696F6E54656D706C6174652C0A09090909';
wwv_flow_api.g_varchar2_table(24) := '227265706F7274547970652209093A2073656C662E6F7074696F6E732E7265706F7274547970652C0A09090909227265706F727454656D706C61746522093A2073656C662E6F7074696F6E732E7265706F727454656D706C6174652C2020202020202020';
wwv_flow_api.g_varchar2_table(25) := '0A0909097D3B0A09090973656C662E636F6C756D6E50726F70657274696573203D207B0A0909090922636F6C756D6E4E616D652209093A2073656C662E6F7074696F6E732E636F6C756D6E4E616D652C0A0909090922636F6C756D6E4964220909093A20';
wwv_flow_api.g_varchar2_table(26) := '73656C662E6F7074696F6E732E636F6C756D6E49642C0A0909090922636F6C756D6E496E6465782209093A2024282723272B73656C662E6F7074696F6E732E636F6C756D6E4964292E696E64657828292C0A090909092269724C696D6974436F6C576964';
wwv_flow_api.g_varchar2_table(27) := '746822093A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F66282749525F4C494D49545F434F4C';
wwv_flow_api.g_varchar2_table(28) := '5F57494454482729203E202D312C200A0909097D3B0A09090973656C662E73656C656374696F6E50726F70657274696573203D207B0A0909090922616C6C6F774D756C7469706C6553656C656374696F6E22093A2073656C662E6F7074696F6E732E7365';
wwv_flow_api.g_varchar2_table(29) := '6C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F662827414C4C4F575F4D554C5449504C452729203E202D312C0A090909092273656C6563';
wwv_flow_api.g_varchar2_table(30) := '744F6E436C69636B416E7977686572652209093A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F';
wwv_flow_api.g_varchar2_table(31) := '66282753454C4543545F4F4E5F524F575F434C49434B2729203E202D312C0A090909092273656C656374696F6E436F6C6F72220909093A2073656C662E6F7074696F6E732E73656C656374696F6E436F6C6F722C0A0909090922637573746F6D43686563';
wwv_flow_api.g_varchar2_table(32) := '6B626F785374796C652209093A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F66282743555354';
wwv_flow_api.g_varchar2_table(33) := '4F4D5F434845434B424F585F5354594C452729203E202D312C0A0909090922656D707479436865636B626F7849636F6E220909093A2073656C662E6F7074696F6E732E656D707479436865636B626F7849636F6E2C0A090909092273656C656374656443';
wwv_flow_api.g_varchar2_table(34) := '6865636B626F7849636F6E2209093A2073656C662E6F7074696F6E732E73656C6563746564436865636B626F7849636F6E0A0909097D3B0A09090973656C662E73746F7261676550726F70657274696573203D207B0A090909092273746F726553656C65';
wwv_flow_api.g_varchar2_table(35) := '63746564496E4974656D2209093A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F66282753544F';
wwv_flow_api.g_varchar2_table(36) := '52455F494E5F4954454D2729203E202D312C0A090909092273746F726553656C6563746564496E436F6C6C656374696F6E22203A2073656C662E6F7074696F6E732E73656C656374696F6E53657474696E677320213D206E756C6C2026262073656C662E';
wwv_flow_api.g_varchar2_table(37) := '6F7074696F6E732E73656C656374696F6E53657474696E67732E696E6465784F66282753544F52455F494E5F434F4C4C454354494F4E2729203E202D312C20202020202020200A090909092273746F726167654974656D4E616D65220909093A2073656C';
wwv_flow_api.g_varchar2_table(38) := '662E6F7074696F6E732E73746F726167654974656D4E616D652C0A09090909226974656D4175746F5375626D6974220909093A2073656C662E6F7074696F6E732E6974656D4175746F5375626D6974203D3D3D20275927203F2074727565203A2066616C';
wwv_flow_api.g_varchar2_table(39) := '73652C0A090909092273746F72616765436F6C6C656374696F6E4E616D652209093A2073656C662E6F7074696F6E732E73746F72616765436F6C6C656374696F6E4E616D652C0A090909092276616C7565536570617261746F72220909093A2073656C66';
wwv_flow_api.g_varchar2_table(40) := '2E6F7074696F6E732E76616C7565536570617261746F722C0A09090909226C696D697453656C656374696F6E220909093A2073656C662E6F7074696F6E732E6C696D697453656C656374696F6E20200A0909097D3B0A0A0909096966202873656C662E5F';
wwv_flow_api.g_varchar2_table(41) := '636865636B49665265706F727454797065537570706F727465642829203D3D2066616C7365297B0A0909090973656C662E5F7468726F774572726F7228275F637265617465272C2073656C662E435F4552524F525F5245504F52545F4E4F545F53555050';
wwv_flow_api.g_varchar2_table(42) := '4F525445442C2074727565293B0A0909097D0A0909096966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D203D3D20747275652026262073656C662E5F636865636B49664974656D457869';
wwv_flow_api.g_varchar2_table(43) := '7374732829203D3D2066616C7365297B0A0909090973656C662E5F7468726F774572726F7228275F637265617465272C2073656C662E435F4552524F525F4954454D5F444F45535F4E4F545F45584953542C2066616C7365293B0A0909097D0A0909090A';
wwv_flow_api.g_varchar2_table(44) := '0909092F2F20544F20444F202D2068616E646C6520646966666572656E7420636C6173736963207265706F72742074656D706C617465730A0909092F2F20544F20444F202D2068616E646C6520646966666572656E74207265706F72742074797065730A';
wwv_flow_api.g_varchar2_table(45) := '0A09090973656C662E726567696F6E24203D2024282723272B73656C662E7265706F727450726F706572746965732E726567696F6E4964293B0A0A09090973656C662E726567696F6E242E6F6E282761706578616674657272656672657368272C206675';
wwv_flow_api.g_varchar2_table(46) := '6E6374696F6E202829207B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027416674657220726566726573682070726F63657373696E672E2E2E20';
wwv_flow_api.g_varchar2_table(47) := '27293B0A0909090973656C662E5F66696E64436865636B626F78436F6C756D6E28293B0A0909090973656C662E5F72656E646572436865636B626F78657328293B0A0909090973656C662E5F616464436C69636B4C697374656E65727328293B0A090909';
wwv_flow_api.g_varchar2_table(48) := '0973656C662E5F6170706C7953656C656374696F6E28293B0A0909097D293B0A0A09090973656C662E5F66696E64436865636B626F78436F6C756D6E28293B0A09090973656C662E5F72656E646572436865636B626F78657328293B0A09090973656C66';
wwv_flow_api.g_varchar2_table(49) := '2E5F616464436C69636B4C697374656E65727328293B20202020200A09090973656C662E5F67657453746F72656456616C75657328293B0A0909090A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073';
wwv_flow_api.g_varchar2_table(50) := '656C662E435F4C4F475F5052454649582C202757696467657420696E697469616C697A6564207375636365737366756C6C793A2027293B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E';
wwv_flow_api.g_varchar2_table(51) := '435F4C4F475F5052454649582C20275265706F72743A20272C2073656C662E726567696F6E24293B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027';
wwv_flow_api.g_varchar2_table(52) := '4865616465723A20272C2073656C662E636F6C756D6E48656164657224293B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202743656C6C733A202720';
wwv_flow_api.g_varchar2_table(53) := '2C2073656C662E636F6C756D6E43656C6C7324293B2020202020200A09097D2C0A090A09092F2F206A5175657279207769646765742070726976617465206D6574686F64730A0A09095F636865636B49665265706F727454797065537570706F72746564';
wwv_flow_api.g_varchar2_table(54) := '3A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C2027436865636B696E67206966';
wwv_flow_api.g_varchar2_table(55) := '207265706F7274207479706520697320737570706F727465642E2E2E27293B0A0A09090972657475726E2073656C662E435F535550504F525445445F5245504F52545F54595045532E696E636C756465732873656C662E7265706F727450726F70657274';
wwv_flow_api.g_varchar2_table(56) := '6965732E7265706F727454797065293B20202020200A09097D2C0A0A09095F636865636B49664974656D4578697374733A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873';
wwv_flow_api.g_varchar2_table(57) := '656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C2027436865636B696E672069662061706578206974656D206578697374732E2E2E27293B0A0A09090972657475726E20617065782E6974656D2873656C662E7374';
wwv_flow_api.g_varchar2_table(58) := '6F7261676550726F706572746965732E73746F726167654974656D4E616D65292E6E6F64653B20202020200A09097D2C0A0A09095F66696E64436865636B626F78436F6C756D6E3A2066756E6374696F6E28297B0A0909097661722073656C66203D2074';
wwv_flow_api.g_varchar2_table(59) := '6869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202746696E64696E6720636865636B626F7820636F6C756D6E2E2E2E27293B0A0A0909090A0909097365';
wwv_flow_api.g_varchar2_table(60) := '6C662E636F6C756D6E48656164657224203D2073656C662E726567696F6E242E66696E642827746823272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E4964293B0A09090973656C662E636F6C756D6E43656C6C732420203D20';
wwv_flow_api.g_varchar2_table(61) := '73656C662E726567696F6E242E66696E64282774645B686561646572733D22272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E49642B27225D27293B0A09097D2C0A0A09092F2F2046756E6374696F6E2072656E646572732063';
wwv_flow_api.g_varchar2_table(62) := '6865636B626F78657320617661696C61626C6520616674657220696E2073656C662E63656C6C436865636B626F7865732420616E642073656C662E686561646572436865636B626F78240A09095F72656E646572436865636B626F7865733A2066756E63';
wwv_flow_api.g_varchar2_table(63) := '74696F6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202752656E646572696E6720636865636B626F';
wwv_flow_api.g_varchar2_table(64) := '7865732E2E2E27293B0A0909090A0909096966202873656C662E73656C656374696F6E50726F706572746965732E637573746F6D436865636B626F785374796C65297B0A090909092F2F2072656E646572696E6720636F6C756D6E20636865636B626F78';
wwv_flow_api.g_varchar2_table(65) := '6573202D20637573746F6D207374796C650A0909090973656C662E636F6C756D6E43656C6C73242E656163682866756E6374696F6E28297B0A09090909096C6574200A09090909090963656C6C2420202020202020202020203D20242874686973292C0A';
wwv_flow_api.g_varchar2_table(66) := '09090909090963656C6C56616C7565202020202020203D2063656C6C242E7465787428292C0A09090909090976616C756541747472696275746520203D20272076616C75653D22272B63656C6C56616C75652B272220272C0A090909090909636865636B';
wwv_flow_api.g_varchar2_table(67) := '626F78242009093D202428273C7370616E20636C6173733D227073636320666120272B73656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E2B272220272B2076616C7565417474726962757465202B';
wwv_flow_api.g_varchar2_table(68) := '273E3C2F7370616E3E27293B0A0A090909090963656C6C242E68746D6C28636865636B626F7824293B0A090909097D293B0A0909090973656C662E63656C6C436865636B626F78657324203D2073656C662E636F6C756D6E43656C6C73242E66696E6428';
wwv_flow_api.g_varchar2_table(69) := '277370616E2E7073636327293B0A0A090909092F2F2072656E646572696E672068656164657220636865636B626F78202D20637573746F6D207374796C650A090909096C65740A0909090909686561646572436865636B626F7824202020203D20242827';
wwv_flow_api.g_varchar2_table(70) := '3C7370616E20636C6173733D227073636320666120272B73656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E2B27223E3C2F7370616E3E27293B0A0A0909090973656C662E636F6C756D6E48656164';
wwv_flow_api.g_varchar2_table(71) := '6572242E66696E6428276127292E72656D6F766528293B0A0909090973656C662E636F6C756D6E486561646572242E66696E6428277370616E27292E72656D6F766528293B0A0909090973656C662E636F6C756D6E486561646572242E636F6E74656E74';
wwv_flow_api.g_varchar2_table(72) := '7328292E66696C7465722866756E6374696F6E2829207B0A090909090972657475726E20746869732E6E6F646554797065203D3D204E6F64652E544558545F4E4F44453B0A090909097D292E72656D6F766528293B202020200A0A0909090973656C662E';
wwv_flow_api.g_varchar2_table(73) := '636F6C756D6E486561646572242E617070656E6428686561646572436865636B626F7824293B0A0909090973656C662E686561646572436865636B626F7824203D20686561646572436865636B626F78243B0A090909092F2F20666F7220736F6D652072';
wwv_flow_api.g_varchar2_table(74) := '6561736F6E2041504558204952206973206E6F74206265686176696E67206772656174207768656E2074686572652061726520616E79206368616E67657320696E207461626C6520686561646572730A090909092F2F20726573756C74696E6720696E20';
wwv_flow_api.g_varchar2_table(75) := '626C616E6B20737061636520616464656420756E64657220746865206865616465722E20526573697A696E67207468652077696E646F7720616C6C6F772049522077696467657420746F20726563616C63756C6174650A090909092F2F20737061636520';
wwv_flow_api.g_varchar2_table(76) := '6E656564656420666F72206865616465727320616E6420666978207468652069737375652C20736F206C65742773206D616B652069742073696D706C6520616E64206A7573742073696D756C6174652077696E646F7720726573697A652E0A0909090961';
wwv_flow_api.g_varchar2_table(77) := '7065782E6576656E742E747269676765722827626F6479272C20276170657877696E646F77726573697A656427293B200A0909097D20656C7365207B0A090909092F2F2072656E646572696E6720636F6C756D6E20636865636B626F786573202D207374';
wwv_flow_api.g_varchar2_table(78) := '616E646172642048544D4C0A0909090973656C662E636F6C756D6E43656C6C73242E656163682866756E6374696F6E28297B0A09090909096C6574200A09090909090963656C6C2420202020202020202020203D20242874686973292C0A090909090909';
wwv_flow_api.g_varchar2_table(79) := '63656C6C56616C7565202020202020203D2063656C6C242E7465787428292C0A09090909090976616C756541747472696275746520203D20272076616C75653D22272B63656C6C56616C75652B272220272C0A090909090909636865636B626F78242009';
wwv_flow_api.g_varchar2_table(80) := '093D202428273C696E70757420747970653D22636865636B626F7822272B2076616C7565417474726962757465202B273E27293B0A0A090909090963656C6C242E68746D6C28636865636B626F7824293B0A090909097D293B0A0909090973656C662E63';
wwv_flow_api.g_varchar2_table(81) := '656C6C436865636B626F78657324203D2073656C662E636F6C756D6E43656C6C73242E66696E642827696E7075745B747970653D22636865636B626F78225D27293B0A0A090909092F2F2072656E646572696E672068656164657220636865636B626F78';
wwv_flow_api.g_varchar2_table(82) := '202D207374616E646172642048544D4C0A090909097661720A090909090964697361626C656441747472696275746520203D202173656C662E73656C656374696F6E50726F706572746965732E616C6C6F774D756C7469706C6553656C656374696F6E20';
wwv_flow_api.g_varchar2_table(83) := '3F20272064697361626C65642027203A2027272C0A0909090909686561646572436865636B626F7824202020203D202428273C696E70757420747970653D22636865636B626F7822272B2064697361626C65644174747269627574652B273E27293B0A0A';
wwv_flow_api.g_varchar2_table(84) := '0909090973656C662E636F6C756D6E486561646572242E66696E6428276127292E72656D6F766528293B0A0909090973656C662E636F6C756D6E486561646572242E66696E6428277370616E27292E72656D6F766528293B0A0909090973656C662E636F';
wwv_flow_api.g_varchar2_table(85) := '6C756D6E486561646572242E636F6E74656E747328292E66696C7465722866756E6374696F6E2829207B0A090909090972657475726E20746869732E6E6F646554797065203D3D204E6F64652E544558545F4E4F44453B0A090909097D292E72656D6F76';
wwv_flow_api.g_varchar2_table(86) := '6528293B202020200A0A0909090973656C662E636F6C756D6E486561646572242E617070656E6428686561646572436865636B626F7824293B0A0909090973656C662E686561646572436865636B626F7824203D20686561646572436865636B626F7824';
wwv_flow_api.g_varchar2_table(87) := '3B0A0909097D0A0A0909092F2F204C696D697420636F6C756D6E20776964746820666F72204952200A0909096966202873656C662E7265706F727450726F706572746965732E7265706F727454797065203D3D2027496E74657261637469766520526570';
wwv_flow_api.g_varchar2_table(88) := '6F7274272026262073656C662E636F6C756D6E50726F706572746965732E69724C696D6974436F6C576964746829207B0A0909090924280A09090909092723272B73656C662E7265706F727450726F706572746965732E726567696F6E4964202B202720';
wwv_flow_api.g_varchar2_table(89) := '74683A6E74682D6368696C6428272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E496E6465782B312B27292C2027202B0A09090909092723272B73656C662E7265706F727450726F706572746965732E726567696F6E4964202B';
wwv_flow_api.g_varchar2_table(90) := '20272074683A6E74682D6368696C6428272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E496E6465782B312B2729203E206469762C2027202B0A09090909092723272B73656C662E7265706F727450726F706572746965732E72';
wwv_flow_api.g_varchar2_table(91) := '6567696F6E4964202B20272074683A6E74682D6368696C6428272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E496E6465782B312B2729203E20612C2027202B090909090A09090909092723272B73656C662E7265706F727450';
wwv_flow_api.g_varchar2_table(92) := '726F706572746965732E726567696F6E4964202B20272074643A6E74682D6368696C6428272B73656C662E636F6C756D6E50726F706572746965732E636F6C756D6E496E6465782B312B2729270A09090909292E637373287B20277769647468273A2027';
wwv_flow_api.g_varchar2_table(93) := '34307078277D293B0A0909090A09090909617065782E6576656E742E747269676765722827626F6479272C20276170657877696E646F77726573697A656427293B200A0909097D0A09090924282723272B73656C662E636F6C756D6E50726F7065727469';
wwv_flow_api.g_varchar2_table(94) := '65732E636F6C756D6E4964292E637373287B27766572746963616C2D616C69676E273A20276D6964646C65277D293B200A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649';
wwv_flow_api.g_varchar2_table(95) := '582C202763656C6C436865636B626F786573243A20272C2073656C662E63656C6C436865636B626F78657324293B0A09097D2C0A0A09095F616464436C69636B4C697374656E6572733A2066756E6374696F6E28297B0A0909097661722073656C66203D';
wwv_flow_api.g_varchar2_table(96) := '20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C2027416464696E6720636C69636B206C697374656E6572732E2E2E27293B0A0A0909092F2F204164';
wwv_flow_api.g_varchar2_table(97) := '642063656C6C20636865636B626F78206C697374656E6572730A09090973656C662E63656C6C436865636B626F786573242E656163682866756E6374696F6E28297B0A090909096C6574200A0909090909636865636B626F7824203D2024287468697329';
wwv_flow_api.g_varchar2_table(98) := '2C0A0909090909706172656E74526F77203D20242874686973292E636C6F736573742827747227293B0A0A090909096966202873656C662E73656C656374696F6E50726F706572746965732E73656C6563744F6E436C69636B416E797768657265297B0A';
wwv_flow_api.g_varchar2_table(99) := '09090909096966202873656C662E73656C656374696F6E50726F706572746965732E616C6C6F774D756C7469706C6553656C656374696F6E297B0A090909090909706172656E74526F772E6F6E2827636C69636B272C20242E70726F7879282073656C66';
wwv_flow_api.g_varchar2_table(100) := '2E5F6D756C7469706C6553656C656374696F6E48616E646C65722C2073656C662C20636865636B626F782429293B202F2F2032202D20726F772073656C656374696F6E2C206D756C7469706C650A09090909097D20656C7365207B0A0909090909097061';
wwv_flow_api.g_varchar2_table(101) := '72656E74526F772E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73696E676C6553656C656374696F6E48616E646C65722C2073656C662C20636865636B626F782429293B2020202F2F2031202D20726F772073656C656374696F6E';
wwv_flow_api.g_varchar2_table(102) := '2C2073696E676C650A09090909097D200A090909097D20656C7365207B0A09090909096966202873656C662E73656C656374696F6E50726F706572746965732E616C6C6F774D756C7469706C6553656C656374696F6E297B0A090909090909636865636B';
wwv_flow_api.g_varchar2_table(103) := '626F78242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F6D756C7469706C6553656C656374696F6E48616E646C65722C2073656C662C20636865636B626F782429293B2020202F2F2033202D20636865636B626F782073656C6563';
wwv_flow_api.g_varchar2_table(104) := '69746F6E2C2073696E676C650A09090909097D20656C7365207B0A090909090909636865636B626F78242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73696E676C6553656C656374696F6E48616E646C65722C2073656C662C20';
wwv_flow_api.g_varchar2_table(105) := '636865636B626F782429293B202F2F2034202D20636865636B626F782073656C656374696F6E2C206D756C7469706C652020200A09090909097D0A090909097D0A0909097D293B200A0909090A0909092F2F204164642068656164657220636865636B62';
wwv_flow_api.g_varchar2_table(106) := '6F78206C697374656E65720A0909096966202873656C662E73656C656374696F6E50726F706572746965732E616C6C6F774D756C7469706C6553656C656374696F6E297B0A090909096966202873656C662E73656C656374696F6E50726F706572746965';
wwv_flow_api.g_varchar2_table(107) := '732E73656C6563744F6E436C69636B416E797768657265297B0A090909090973656C662E636F6C756D6E486561646572242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73656C656374416C6C48616E646C65722C2073656C6629';
wwv_flow_api.g_varchar2_table(108) := '293B0A090909097D20656C7365207B0A090909090973656C662E686561646572436865636B626F78242E6F6E2827636C69636B272C20242E70726F7879282073656C662E5F73656C656374416C6C48616E646C65722C2073656C6629293B0A090909097D';
wwv_flow_api.g_varchar2_table(109) := '0A0909097D0A09097D2C0A0A09095F73696E676C6553656C656374696F6E48616E646C65723A2066756E6374696F6E2870436865636B626F78242C20704576656E74297B0A090909766172200A0909090973656C6620203D20746869732C0A0909090976';
wwv_flow_api.g_varchar2_table(110) := '616C7565203D2070436865636B626F78242E61747472282776616C756527293B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202753696E676C652073';
wwv_flow_api.g_varchar2_table(111) := '656C656374696F6E2068616E646C657220747269676765726564206279206576656E743A20272C20704576656E74293B0A0909090A0A0909096966202873656C662E73656C656374656456616C7565732E696E636C756465732876616C75652929207B0A';
wwv_flow_api.g_varchar2_table(112) := '0909090973656C662E5F636C65617253656C656374656456616C75657328293B0A0909097D20656C7365207B0A0909090973656C662E5F636C65617253656C656374656456616C75657328293B0A0909090973656C662E5F616464546F53656C65637465';
wwv_flow_api.g_varchar2_table(113) := '6456616C7565732876616C7565293B0A0909097D0A0A09090973656C662E5F6170706C7953656C656374696F6E28293B0A09090973656C662E5F73746F726556616C75657328293B20200A09097D2C0A0A09095F6D756C7469706C6553656C656374696F';
wwv_flow_api.g_varchar2_table(114) := '6E48616E646C65723A2066756E6374696F6E2870436865636B626F78242C20704576656E74297B0A090909766172200A0909090973656C6620203D20746869732C0A0909090976616C7565203D2070436865636B626F78242E61747472282776616C7565';
wwv_flow_api.g_varchar2_table(115) := '27293B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C20274D756C7469706C652073656C656374696F6E2068616E646C65722074726967676572656420';
wwv_flow_api.g_varchar2_table(116) := '6279206576656E743A20272C20704576656E74293B0A0A0909096966202873656C662E73656C656374656456616C7565732E696E636C756465732876616C75652929207B0A0909090973656C662E5F72656D6F766546726F6D53656C656374656456616C';
wwv_flow_api.g_varchar2_table(117) := '7565732876616C7565293B0A0909097D20656C7365207B0A0909090973656C662E5F616464546F53656C656374656456616C7565732876616C7565293B0A0909097D2020202020200A09090973656C662E5F6170706C7953656C656374696F6E28293B0A';
wwv_flow_api.g_varchar2_table(118) := '09090973656C662E5F73746F726556616C75657328293B200A09097D2C20200A0A09095F73656C656374416C6C48616E646C65723A2066756E6374696F6E28704576656E74297B0A0909097661722073656C66203D20746869733B0A0909096465627567';
wwv_flow_api.g_varchar2_table(119) := '2E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202753656C65637420616C6C2068616E646C657220747269676765726564206279206576656E743A20272C20704576656E7429';
wwv_flow_api.g_varchar2_table(120) := '3B20200A0A0909092F2F2050617274206F6620636F646520666F7220637573746F6D20636865636B626F78207374796C65206F6E6C790A0909096966202873656C662E73656C656374696F6E50726F706572746965732E637573746F6D436865636B626F';
wwv_flow_api.g_varchar2_table(121) := '785374796C6529207B0A090909090A090909096966202873656C662E686561646572436865636B626F78242E686173436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E29297B0A09';
wwv_flow_api.g_varchar2_table(122) := '090909092F2F20696620636865636B626F7820697320656D707479202D3E207468656E2073656C65637420697420616E6420616C6C2076697369626C650A090909090973656C662E686561646572436865636B626F78240A0909090909092E72656D6F76';
wwv_flow_api.g_varchar2_table(123) := '65436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E290A0909090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C6563746564';
wwv_flow_api.g_varchar2_table(124) := '436865636B626F7849636F6E293B0A090909090973656C662E63656C6C436865636B626F786573242E656163682866756E6374696F6E28297B0A0909090909096C6574200A09090909090909636865636B626F7824203D20242874686973292C0A090909';
wwv_flow_api.g_varchar2_table(125) := '0909090976616C7565202020203D20636865636B626F78242E61747472282776616C756527293B0A09090909090973656C662E5F616464546F53656C656374656456616C7565732876616C7565293B0A09090909097D293B0A0A090909097D20656C7365';
wwv_flow_api.g_varchar2_table(126) := '207B0A09090909092F2F20696620636865636B626F7820697320636865636B6564207468656E20636C65617220697420616E6420616C6C2076697369626C65200A090909090973656C662E686561646572436865636B626F78240A0909090909092E7265';
wwv_flow_api.g_varchar2_table(127) := '6D6F7665436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E290A0909090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D';
wwv_flow_api.g_varchar2_table(128) := '707479436865636B626F7849636F6E293B0A090909090973656C662E63656C6C436865636B626F786573242E656163682866756E6374696F6E28297B0A0909090909096C6574200A09090909090909636865636B626F7824203D20242874686973292C0A';
wwv_flow_api.g_varchar2_table(129) := '0909090909090976616C7565202020203D20636865636B626F78242E61747472282776616C756527293B0A09090909090973656C662E5F72656D6F766546726F6D53656C656374656456616C7565732876616C7565293B0A09090909097D293B090A0909';
wwv_flow_api.g_varchar2_table(130) := '09097D0A0A0909092F2F2050617274206F6620636F646520666F72207374616E646172642048544D4C20636865636B626F780A0909097D20656C7365207B0A090909092F2F20696620636C69636B20776173206E6F7420696E2074686520636865636B62';
wwv_flow_api.g_varchar2_table(131) := '6F782C206265636175736520636865636B626F782077696C6C20636865636B20697473656C660A0909090969662028212428704576656E742E746172676574292E69732873656C662E686561646572436865636B626F78242929207B0A09090909097365';
wwv_flow_api.g_varchar2_table(132) := '6C662E686561646572436865636B626F78242E70726F702827636865636B6564272C202173656C662E686561646572436865636B626F78242E70726F702827636865636B65642729293B0A090909097D0A090909096966202873656C662E686561646572';
wwv_flow_api.g_varchar2_table(133) := '436865636B626F78242E70726F702827636865636B65642729297B0A09090909092F2F2073656C65637420616C6C2076697369626C650A090909090973656C662E63656C6C436865636B626F786573242E656163682866756E6374696F6E28297B0A0909';
wwv_flow_api.g_varchar2_table(134) := '090909096C6574200A09090909090909636865636B626F7824203D20242874686973292C0A0909090909090976616C7565202020203D20636865636B626F78242E61747472282776616C756527293B0A09090909090973656C662E5F616464546F53656C';
wwv_flow_api.g_varchar2_table(135) := '656374656456616C7565732876616C7565293B0A09090909097D293B0A090909097D20656C7365207B0A09090909092F2F20636C65617220616C6C2076697369626C650A090909090973656C662E63656C6C436865636B626F786573242E656163682866';
wwv_flow_api.g_varchar2_table(136) := '756E6374696F6E28297B0A0909090909096C6574200A09090909090909636865636B626F7824203D20242874686973292C0A0909090909090976616C7565202020203D20636865636B626F78242E61747472282776616C756527293B0A09090909090973';
wwv_flow_api.g_varchar2_table(137) := '656C662E5F72656D6F766546726F6D53656C656374656456616C7565732876616C7565293B0A09090909097D293B0A090909097D0A0909097D0A0A09090973656C662E5F6170706C7953656C656374696F6E28293B200A09090973656C662E5F73746F72';
wwv_flow_api.g_varchar2_table(138) := '6556616C75657328293B0A0909090A09097D2C0A0A09095F6170706C7953656C656374696F6E3A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F';
wwv_flow_api.g_varchar2_table(139) := '4C564C5F362C2073656C662E435F4C4F475F5052454649582C20274170706C79696E672076697375616C207374796C6520746F2073656C656374656420726F77732E2E2E27293B20202020200A0A0909092F2F20636C65617220616C6C206362780A0909';
wwv_flow_api.g_varchar2_table(140) := '096966202873656C662E73656C656374696F6E50726F706572746965732E637573746F6D436865636B626F785374796C65297B0A0909090973656C662E63656C6C436865636B626F786573240A09090909092E72656D6F7665436C6173732873656C662E';
wwv_flow_api.g_varchar2_table(141) := '73656C656374696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E290A09090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E29';
wwv_flow_api.g_varchar2_table(142) := '3B0A0909090973656C662E686561646572436865636B626F78240A09090909092E72656D6F7665436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E290A09090909092E6164';
wwv_flow_api.g_varchar2_table(143) := '64436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D707479436865636B626F7849636F6E293B0A0909097D20656C7365207B0A0909090973656C662E63656C6C436865636B626F786573242E70726F702827636865636B';
wwv_flow_api.g_varchar2_table(144) := '6564272C2066616C7365293B0A0909090973656C662E686561646572436865636B626F78242E70726F702827636865636B6564272C2066616C7365293B0A0909097D0A0909092F2F2072656D6F76652073656C656374656420726F77207374796C65730A';
wwv_flow_api.g_varchar2_table(145) := '09090973656C662E63656C6C436865636B626F786573242E636C6F736573742827747227292E72656D6F7665436C6173732873656C662E435F53454C45435445445F524F575F434C415353293B0A0A0909092F2F2073656C65637420636865636B626F78';
wwv_flow_api.g_varchar2_table(146) := '6573206163636F7264696E6720746F2073656C65637465642076616C7565732061727261790A0909092F2F20616464207374796C6520746F2073656C656374656420726F77730A09090973656C662E63656C6C436865636B626F786573242E6561636828';
wwv_flow_api.g_varchar2_table(147) := '66756E6374696F6E28297B0A090909096C6574200A0909090909636865636B626F7824203D20242874686973292C0A090909090976616C756520202020203D20636865636B626F78242E61747472282776616C756527292C0A0909090909726F77242020';
wwv_flow_api.g_varchar2_table(148) := '202020203D20636865636B626F78242E636C6F736573742827747227293B0A090909096966202873656C662E73656C656374656456616C7565732E696E636C756465732876616C756529297B0A09090909096966202873656C662E73656C656374696F6E';
wwv_flow_api.g_varchar2_table(149) := '50726F706572746965732E637573746F6D436865636B626F785374796C65297B0A090909090909636865636B626F78240A090909090909092E72656D6F7665436C6173732873656C662E73656C656374696F6E50726F706572746965732E656D70747943';
wwv_flow_api.g_varchar2_table(150) := '6865636B626F7849636F6E290A090909090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E293B0A09090909097D20656C7365207B0A0909090909096368';
wwv_flow_api.g_varchar2_table(151) := '65636B626F78242E70726F702827636865636B6564272C2074727565293B0A09090909097D0A09090909090A0909090909726F77242E616464436C6173732873656C662E435F53454C45435445445F524F575F434C415353293B0A090909097D200A0909';
wwv_flow_api.g_varchar2_table(152) := '097D293B0A0A0909092F2F20636865636B2069662068656164657220636865636B626F782073686F756C6420626520636865636B65640A0909096966202873656C662E73656C656374696F6E50726F706572746965732E637573746F6D436865636B626F';
wwv_flow_api.g_varchar2_table(153) := '785374796C65297B200A090909096966202873656C662E63656C6C436865636B626F786573242E6C656E677468203D3D3D2073656C662E63656C6C436865636B626F786573242E66696C74657228272E272B73656C662E73656C656374696F6E50726F70';
wwv_flow_api.g_varchar2_table(154) := '6572746965732E73656C6563746564436865636B626F7849636F6E292E6C656E677468297B0A090909090973656C662E686561646572436865636B626F78240A0909090909092E72656D6F7665436C6173732873656C662E73656C656374696F6E50726F';
wwv_flow_api.g_varchar2_table(155) := '706572746965732E656D707479436865636B626F7849636F6E290A0909090909092E616464436C6173732873656C662E73656C656374696F6E50726F706572746965732E73656C6563746564436865636B626F7849636F6E293B0A090909097D0A090909';
wwv_flow_api.g_varchar2_table(156) := '7D20656C7365207B0A090909096966202873656C662E63656C6C436865636B626F786573242E6C656E677468203D3D3D2073656C662E63656C6C436865636B626F786573242E66696C74657228273A636865636B656427292E6C656E677468297B0A0909';
wwv_flow_api.g_varchar2_table(157) := '09090973656C662E686561646572436865636B626F78242E70726F702827636865636B6564272C2074727565293B0A090909097D0A0909097D0A0A0A09097D2C20200A09200A09095F616464546F53656C656374656456616C7565733A2066756E637469';
wwv_flow_api.g_varchar2_table(158) := '6F6E287056616C7565297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027416464696E67207661';
wwv_flow_api.g_varchar2_table(159) := '6C756520746F2063757272656E746C792073656C656374656420726F77733A20272C207056616C7565293B0A0909090A090909696620282173656C662E73656C656374656456616C7565732E696E636C75646573287056616C756529297B0A0909090973';
wwv_flow_api.g_varchar2_table(160) := '656C662E73656C656374656456616C7565732E70757368287056616C7565293B0A0909097D2020202020200A09097D2C0A09095F72656D6F766546726F6D53656C656374656456616C7565733A2066756E6374696F6E287056616C7565297B0A09090976';
wwv_flow_api.g_varchar2_table(161) := '61722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C202752656D6F76696E672076616C75652066726F6D206375727265';
wwv_flow_api.g_varchar2_table(162) := '6E746C792073656C656374656420726F77733A20272C207056616C7565293B0A0A09090973656C662E73656C656374656456616C7565732E73706C6963652873656C662E73656C656374656456616C7565732E696E6465784F66287056616C7565292C20';
wwv_flow_api.g_varchar2_table(163) := '31293B0A09097D2C20202020202020200A09095F636C65617253656C656374656456616C7565733A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F47';
wwv_flow_api.g_varchar2_table(164) := '5F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027436C656172696E672073656C65637465642076616C7565732E2E2E27293B0A0A09090973656C662E73656C656374656456616C756573203D205B5D3B2020202020202020';
wwv_flow_api.g_varchar2_table(165) := '2020200A09097D2C202020200A0A09095F67657453746F72656456616C7565733A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A09090973656C662E73656C656374656456616C756573203D20205B5D3B202F2F2069';
wwv_flow_api.g_varchar2_table(166) := '6E697469616C697A6520656D7074792061727261790A0909090A0909092F2F2069662073656C656374696F6E2069732073746F72656420696E20636F6C6C656374696F6E207468656E2074727920746F20726561642069740A0909096966202873656C66';
wwv_flow_api.g_varchar2_table(167) := '2E73746F7261676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E297B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052';
wwv_flow_api.g_varchar2_table(168) := '454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820636F6C6C656374696F6E2E2E2E27293B0A090909096C65740A0909090909616A617844617461203D207B0A09090909090922783031223A2022';
wwv_flow_api.g_varchar2_table(169) := '474554222C0A09090909090922783033223A2073656C662E73746F7261676550726F706572746965732E73746F72616765436F6C6C656374696F6E4E616D650A09090909097D2C0A0909090909616A61784F7074696F6E73203D207B0A09090909090922';
wwv_flow_api.g_varchar2_table(170) := '73756363657373222020202020202020202020202020202020203A20242E70726F78792873656C662E5F67657453746F72656456616C756573416A6178737563636573732C2020202073656C66292C0A090909090909226572726F722220202020202020';
wwv_flow_api.g_varchar2_table(171) := '202020202020202020202020203A20242E70726F78792873656C662E5F67657453746F72656456616C756573416A61786572726F722C20202020202073656C66292C0A090909090909227461726765742220202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(172) := '3A202723272B73656C662E7265706F727450726F706572746965732E726567696F6E49642C0A090909090909226C6F6164696E67496E64696361746F72222020202020202020203A202723272B73656C662E7265706F727450726F706572746965732E72';
wwv_flow_api.g_varchar2_table(173) := '6567696F6E49642C0A090909090909226C6F6164696E67496E64696361746F72506F736974696F6E22203A202263656E7465726564220A09090909097D3B200A09090909090A09090909617065782E7365727665722E706C7567696E20282073656C662E';
wwv_flow_api.g_varchar2_table(174) := '6F7074696F6E732E616A61784964656E7469666965722C20616A6178446174612C20616A61784F7074696F6E7320293B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F';
wwv_flow_api.g_varchar2_table(175) := '5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820636F6C6C656374696F6E2E2E2E272C2027416A61782073656E7427293B20200A0909097D0A0909092F2F2069662073656C656374696F6E';
wwv_flow_api.g_varchar2_table(176) := '206973206E6F742073746F72656420696E20636F6C6C656374696F6E2C206275742069732073746F72656420696E2061706578206974656D207468656E20726561642069740A0909092F2F20616E64206170706C7920746F207265706F72740A09090965';
wwv_flow_api.g_varchar2_table(177) := '6C7365206966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D2026262024762873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D652920213D20';
wwv_flow_api.g_varchar2_table(178) := '2222297B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D2041504558';
wwv_flow_api.g_varchar2_table(179) := '204974656D2E2E2E27293B0A0909090973656C662E73656C656374656456616C756573203D2024762873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D65292E73706C69742873656C662E73746F7261676550';
wwv_flow_api.g_varchar2_table(180) := '726F706572746965732E76616C7565536570617261746F72293B0A0909090973656C662E5F6170706C7953656C656374696F6E28293B0A0909097D200A09097D2C0A09095F67657453746F72656456616C756573416A6178737563636573733A2066756E';
wwv_flow_api.g_varchar2_table(181) := '6374696F6E2870446174612C2070546578745374617475732C20704A71584852297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E43';
wwv_flow_api.g_varchar2_table(182) := '5F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D204150455820636F6C6C656374696F6E2E2E2E272C2027416A61782073756363657373272C2070446174612C207054657874537461747573';
wwv_flow_api.g_varchar2_table(183) := '2C20704A71584852293B0A0A09090973656C662E73656C656374656456616C756573203D2070446174612E73656C656374656456616C7565732E6D6170286F626A203D3E206F626A2E636865636B626F785F76616C7565293B0A09090973656C662E5F61';
wwv_flow_api.g_varchar2_table(184) := '70706C7953656C656374696F6E28293B0A09097D2C0A09095F67657453746F72656456616C756573416A61786572726F723A2066756E6374696F6E28704A715848522C2070546578745374617475732C20704572726F725468726F776E297B0A09090976';
wwv_flow_api.g_varchar2_table(185) := '61722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C756573';
wwv_flow_api.g_varchar2_table(186) := '2066726F6D204150455820636F6C6C656374696F6E2E2E2E272C2027416A6178206572726F72272C20704A715848522C2070546578745374617475732C20704572726F725468726F776E20293B0A0A0909092F2F2069662076616C75652063616E206265';
wwv_flow_api.g_varchar2_table(187) := '206F627461696E65642066726F6D2061706578206974656D207468656E2074727920746F20646F2069740A0909096966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D20297B0A09090909';
wwv_flow_api.g_varchar2_table(188) := '64656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027526573746F72696E672073656C65637465642076616C7565732066726F6D2041504558204974656D2E2E2E27';
wwv_flow_api.g_varchar2_table(189) := '293B0A0909090973656C662E73656C656374656456616C756573203D2024762873656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D65292E73706C69742873656C662E73746F7261676550726F70657274696573';
wwv_flow_api.g_varchar2_table(190) := '2E76616C7565536570617261746F72293B0A0909090973656C662E5F6170706C7953656C656374696F6E28293B0A0909097D200A09090973656C662E5F7468726F774572726F7228275F67657453746F72656456616C756573416A61786572726F72272C';
wwv_flow_api.g_varchar2_table(191) := '2073656C662E435F4552524F525F414A41585F524541445F4641494C5552452C2066616C7365293B0A09097D2C0A0A090A09095F73746F726556616C7565733A2066756E6374696F6E28297B0A0909097661722073656C66203D20746869733B0A0A0909';
wwv_flow_api.g_varchar2_table(192) := '092F2F2073746F72696E672073656C65637465642076616C75657320696E2061706578206974656D200A0909096966202873656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E4974656D297B202020200A0909';
wwv_flow_api.g_varchar2_table(193) := '090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202753746F72696E672073656C65637465642076616C75657320696E2041504558206974656D2E2E2E27293B0A090909';
wwv_flow_api.g_varchar2_table(194) := '092F2F2069662073656C656374696F6E2063616E6E6F7420657863656564206D6178696D756D206C656E67746820696E206279746573207468656E0A090909092F2F2072656D6F7665206C6173742073656C65637465642076616C75657320756E74696C';
wwv_flow_api.g_varchar2_table(195) := '6C20697420666974730A090909096966202873656C662E73746F7261676550726F706572746965732E6C696D697453656C656374696F6E203D3D3D2027592720297B0A09090909096C6574200A090909090909656E636F646572203D206E657720546578';
wwv_flow_api.g_varchar2_table(196) := '74456E636F64657228292C0A09090909090973656C656374696F6E45786365646564203D2066616C73653B0A09090909097768696C65202820656E636F6465722E656E636F6465282073656C662E73656C656374656456616C7565732E6A6F696E287365';
wwv_flow_api.g_varchar2_table(197) := '6C662E73746F7261676550726F706572746965732E76616C7565536570617261746F722920292E6C656E677468203E2073656C662E435F53544F524147455F4954454D5F4D41585F42595445535F434F554E5420297B0A09090909090973656C662E7365';
wwv_flow_api.g_varchar2_table(198) := '6C656374656456616C7565732E706F7028293B0A09090909090973656C656374696F6E45786365646564203D20747275653B0A09090909097D0A09090909096966202873656C656374696F6E45786365646564297B0A09090909090964656275672E6D65';
wwv_flow_api.g_varchar2_table(199) := '73736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C20274C696D6974696E672073656C656374696F6E206C656E67746820746F206D6178696D756D206E756D626572206F6620627974657320272C20';
wwv_flow_api.g_varchar2_table(200) := '73656C662E435F53544F524147455F4954454D5F4D41585F42595445535F434F554E54293B0A090909090909617065782E6576656E742E747269676765722873656C662E726567696F6E242C2073656C662E435F4556454E545F4D41585F53454C454354';
wwv_flow_api.g_varchar2_table(201) := '494F4E5F45584345444544293B0A09090909090973656C662E5F6170706C7953656C656374696F6E28293B0A09090909097D202020202020202020200A090909090924732873656C662E73746F7261676550726F706572746965732E73746F7261676549';
wwv_flow_api.g_varchar2_table(202) := '74656D4E616D652C2073656C662E73656C656374656456616C7565732E6A6F696E2873656C662E73746F7261676550726F706572746965732E76616C7565536570617261746F722920293B0A090909090964656275672E6D6573736167652873656C662E';
wwv_flow_api.g_varchar2_table(203) := '435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202753656C65637465642076616C7565732073746F72656420696E2041504558206974656D207375636365737366756C6C7927293B0A090909097D200A090909090A090909';
wwv_flow_api.g_varchar2_table(204) := '092F2F2069662073656C6C656374696F6E206973206E6F74206C696D69746564207468656E20777269746520697420746F207468652061706578206974656D0A09090909656C7365207B0A090909090924732873656C662E73746F7261676550726F7065';
wwv_flow_api.g_varchar2_table(205) := '72746965732E73746F726167654974656D4E616D652C2073656C662E73656C656374656456616C7565732E6A6F696E2873656C662E73746F7261676550726F706572746965732E76616C7565536570617261746F722920293B0A09090909096465627567';
wwv_flow_api.g_varchar2_table(206) := '2E6D6573736167652873656C662E435F4C4F475F4C564C5F362C2073656C662E435F4C4F475F5052454649582C202753656C65637465642076616C7565732073746F72656420696E2041504558206974656D207375636365737366756C6C7927293B0A09';
wwv_flow_api.g_varchar2_table(207) := '0909097D20202020202020200A0909097D0A0A0909092F2F2073746F72696E672073656C65637465642076616C75657320696E206170657820636F6C6C656374696F6E0A0909096966202873656C662E73746F7261676550726F706572746965732E7374';
wwv_flow_api.g_varchar2_table(208) := '6F726553656C6563746564496E436F6C6C656374696F6E207C7C2073656C662E73746F7261676550726F706572746965732E6974656D4175746F5375626D6974297B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F';
wwv_flow_api.g_varchar2_table(209) := '44454255472C2073656C662E435F4C4F475F5052454649582C2027536176696E672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E2E2E27293B0A09090909';
wwv_flow_api.g_varchar2_table(210) := '6C65740A0909090909616A617844617461203D207B0A09090909090922783031223A2073656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E203F202253455422203A20225355424D49';
wwv_flow_api.g_varchar2_table(211) := '54222C0A09090909090922783032223A2073656C662E73746F7261676550726F706572746965732E73746F726553656C6563746564496E436F6C6C656374696F6E2C0A09090909090922783033223A2073656C662E73746F7261676550726F7065727469';
wwv_flow_api.g_varchar2_table(212) := '65732E73746F72616765436F6C6C656374696F6E4E616D652C0A09090909090922663031223A2073656C662E73656C656374656456616C7565730A09090909097D2C0A0909090909616A61784F7074696F6E73203D207B0A090909090909227375636365';
wwv_flow_api.g_varchar2_table(213) := '737322202020203A20242E70726F78792873656C662E5F73746F726556616C756573416A6178737563636573732C2020202073656C66292C0A090909090909226572726F72222020202020203A20242E70726F78792873656C662E5F73746F726556616C';
wwv_flow_api.g_varchar2_table(214) := '756573416A61786572726F722C20202020202073656C66290A09090909097D3B200A090909096966202873656C662E73746F7261676550726F706572746965732E6974656D4175746F5375626D6974297B0A0909090909616A6178446174612E70616765';
wwv_flow_api.g_varchar2_table(215) := '4974656D73203D205B73656C662E73746F7261676550726F706572746965732E73746F726167654974656D4E616D655D3B0A090909097D0A09090909617065782E7365727665722E706C7567696E20282073656C662E6F7074696F6E732E616A61784964';
wwv_flow_api.g_varchar2_table(216) := '656E7469666965722C20616A6178446174612C20616A61784F7074696F6E7320293B0A0909090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027536176696E';
wwv_flow_api.g_varchar2_table(217) := '672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E2E2E272C2027416A61782073656E7427293B200A0909097D0A09097D2C202020200A0A09095F73746F72';
wwv_flow_api.g_varchar2_table(218) := '6556616C756573416A6178737563636573733A2066756E6374696F6E2870446174612C2070546578745374617475732C20704A71584852297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E';
wwv_flow_api.g_varchar2_table(219) := '435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027536176696E672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E';
wwv_flow_api.g_varchar2_table(220) := '2E2E272C2027416A61782073756363657373272C2070446174612C2070546578745374617475732C20704A71584852293B0A09097D2C0A09095F73746F726556616C756573416A61786572726F723A2066756E6374696F6E28704A715848522C20705465';
wwv_flow_api.g_varchar2_table(221) := '78745374617475732C20704572726F725468726F776E297B0A0909097661722073656C66203D20746869733B0A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649';
wwv_flow_api.g_varchar2_table(222) := '582C2027536176696E672073656C65637465642076616C75657320746F20415045582073657373696F6E20737461746520286974656D2F636F6C6C656374696F6E292E2E2E272C2027416A6178206572726F72272C20704A715848522C20705465787453';
wwv_flow_api.g_varchar2_table(223) := '74617475732C20704572726F725468726F776E20293B0A0A09090973656C662E5F7468726F774572726F7228275F73746F726556616C756573416A61786572726F72272C2073656C662E435F4552524F525F414A41585F53544F52455F4641494C555245';
wwv_flow_api.g_varchar2_table(224) := '2C2066616C7365293B0A09097D2C0A0A09095F7468726F774572726F723A2066756E6374696F6E287046756E6374696F6E4E616D652C20704572726F724D6573736167652C207053746F70506C7567696E2C2070446973706C6179506167654572726F72';
wwv_flow_api.g_varchar2_table(225) := '4D65737361676573297B0A090909766172200A0909090973656C66203D20746869732C0A09090909646973706C6179506167654572726F724D65737361676573203D2070446973706C6179506167654572726F724D65737361676573207C7C2073656C66';
wwv_flow_api.g_varchar2_table(226) := '2E435F444953504C41595F504147455F4552524F525F4D455353414745532C0A09090909656E64557365724572726F724D657373616765203D2073656C662E435F454E445F555345525F4552524F525F505245464958202B20704572726F724D65737361';
wwv_flow_api.g_varchar2_table(227) := '6765202B2073656C662E435F454E445F555345525F4552524F525F5355464649583B0A0909090A09090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F4552524F522C2073656C662E435F4C4F475F5052454649582C20704675';
wwv_flow_api.g_varchar2_table(228) := '6E6374696F6E4E616D652C20704572726F724D657373616765293B0A0909090A09090969662028646973706C6179506167654572726F724D65737361676573297B0A09090909617065782E6D6573736167652E636C6561724572726F727328293B0A0909';
wwv_flow_api.g_varchar2_table(229) := '0909617065782E6D6573736167652E73686F774572726F7273287B0A0909090909747970653A20202020202020226572726F72222C0A09090909096C6F636174696F6E3A2020202270616765222C0A09090909096D6573736167653A20202020656E6455';
wwv_flow_api.g_varchar2_table(230) := '7365724572726F724D6573736167652C0A0909090909756E736166653A202020202066616C73650A090909097D293B0A0909097D0A090909696620287053746F70506C7567696E297B0A090909097468726F77206E6577204572726F7228656E64557365';
wwv_flow_api.g_varchar2_table(231) := '724572726F724D657373616765293B0A0909097D0A09097D2C0A0A092F2F206A517565727920776964676574207075626C6963206D6574686F6473200A0A09636C65617253656C656374696F6E3A2066756E6374696F6E28297B0A09097661722073656C';
wwv_flow_api.g_varchar2_table(232) := '66203D20746869733B0A090964656275672E6D6573736167652873656C662E435F4C4F475F4C564C5F44454255472C2073656C662E435F4C4F475F5052454649582C2027436C6561722073656C656374696F6E207075626C6963206D6574686F6420696E';
wwv_flow_api.g_varchar2_table(233) := '766F6B65642E2E2E27293B200A09090A090973656C662E5F636C65617253656C656374656456616C75657328293B0A090973656C662E5F6170706C7953656C656374696F6E28293B0A090973656C662E5F73746F726556616C75657328293B0A097D2C0A';
wwv_flow_api.g_varchar2_table(234) := '092F2F206A517565727920776964676574206E6174697665206D6574686F64730A095F64657374726F793A2066756E6374696F6E28297B0A097D2C0A0A092F2F206F7074696F6E733A2066756E6374696F6E2820704F7074696F6E7320297B0A092F2F20';
wwv_flow_api.g_varchar2_table(235) := '2020746869732E5F73757065722820704F7074696F6E7320293B0A092F2F207D2C0A095F7365744F7074696F6E3A2066756E6374696F6E2820704B65792C207056616C75652029207B0A09096966202820704B6579203D3D3D202276616C756522202920';
wwv_flow_api.g_varchar2_table(236) := '7B0A0909097056616C7565203D20746869732E5F636F6E73747261696E28207056616C756520293B0A09097D0A0909746869732E5F73757065722820704B65792C207056616C756520293B0A097D2C20200A095F7365744F7074696F6E733A2066756E63';
wwv_flow_api.g_varchar2_table(237) := '74696F6E2820704F7074696F6E732029207B0A0909746869732E5F73757065722820704F7074696F6E7320293B0A097D2C202020200A090A097D293B0A207D2928617065782E64656275672C20617065782E6A517565727920293B0A0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(62303877874690320)
,p_plugin_id=>wwv_flow_api.id(66241640733046753)
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
