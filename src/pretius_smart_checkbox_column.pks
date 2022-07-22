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
