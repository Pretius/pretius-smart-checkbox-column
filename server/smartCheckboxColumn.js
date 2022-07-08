/*
* Plugin: Pretius Smart Checkbox Column
* Version: 1.0.0
*
* Author: Adam Kierzkowski
* Mail: akierzkowski@pretius.com
* Twitter: a_kierzkowski
* Blog: 
*
* Depends:
*    apex/debug.js
*
* Changes:
*
*/

(function (debug, $){
  "use strict";

  $.widget( "pretius.smartCheckboxColumn", {
    // constants
    C_PLUGIN_NAME      : 'Pretius Smart checkbox column',
    C_LOG_PREFIX       : 'Smart checkbox column: ',
    C_LOG_LVL_ERROR    : debug.LOG_LEVEL.ERROR,         // value 1 (end-user)  
    C_LOG_LVL_WARNING  : debug.LOG_LEVEL.WARN,          // value 2 (developer)
    C_LOG_LVL_DEBUG    : debug.LOG_LEVEL.INFO,          // value 4 (debug)
    C_LOG_LVL_6        : debug.LOG_LEVEL.APP_TRACE,     // value 6 
    C_LOG_LVL_9        : debug.LOG_LEVEL.ENGINE_TRACE,  // value 9

    C_SUPPORTED_REPORT_TYPES        : ['Classic Report', 'Interactive Report'],
    C_DISPLAY_PAGE_ERROR_MESSAGES   : true,
    C_END_USER_ERROR_PREFIX         : 'Checkbox functionality error: ',
    C_END_USER_ERROR_SUFFIX         : 'Contact your administrator.',
    C_ERROR_REPORT_NOT_SUPPORTED    : 'Chosen region is not a report or the report type is not supported. ',
    C_ERROR_NO_COLUMN_FOUND         : 'Report column to display checkboxes does not exist. ',
    C_ERROR_CHECKBOXES_DO_NOT_EXIST : 'No checkboxes exist. ',
    C_ERROR_ITEM_DOES_NOT_EXIST     : 'APEX item chosen to store selected values does not exist. ',
    C_ERROR_AJAX_STORE_FAILURE      : 'Storing currently selected rows has failed. ',
    C_ERROR_AJAX_READ_FAILURE       : 'Reading currently selected rows has failed. ',
    C_SELECTED_ROW_CLASS            : 'pscc-selected-row',
    C_STORAGE_ITEM_MAX_BYTES_COUNT  : 4000,
    C_EVENT_MAX_SELECTION_EXCEDED   : 'max_selection_length_exceeded',

    options: {
    },


    // create function
    _create: function(){
      var self = this;
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Starting widget initialization...', 'options: ', self.options);
      self.reportProperties = {
        "regionId"        : self.options.regionId,
        "regionTemplate"  : self.options.regionTemplate,
        "reportType"      : self.options.reportType,
        "reportTemplate"  : self.options.reportTemplate,        
      };
      self.columnProperties = {
        "columnName"      : self.options.columnName,
        "columnId"        : self.options.columnId,       
      };
      self.selectionProperties = {
        "allowMultipleSelection"    : self.options.selectionSettings != null && self.options.selectionSettings.indexOf('ALLOW_MULTIPLE') > -1,
        "selectOnClickAnywhere"     : self.options.selectionSettings != null && self.options.selectionSettings.indexOf('SELECT_ON_ROW_CLICK') > -1,
        "selectionColor"            : self.options.selectionColor
      };
      self.storageProperties = {
        "storeSelectedInItem"       : self.options.selectionSettings != null && self.options.selectionSettings.indexOf('STORE_IN_ITEM') > -1,
        "storeSelectedInCollection" : self.options.selectionSettings != null && self.options.selectionSettings.indexOf('STORE_IN_COLLECTION') > -1,        
        "storageItemName"           : self.options.storageItemName,
        "itemAutoSubmit"            : self.options.itemAutoSubmit === 'Y' ? true : false,
        "storageCollectionName"     : self.options.storageCollectionName,
        "valueSeparator"            : self.options.valueSeparator,
        "limitSelection"            : self.options.limitSelection  
      };

      if (self._checkIfReportTypeSupported() == false){
        self._throwError('_create', self.C_ERROR_REPORT_NOT_SUPPORTED, true);
      }
      if (self.storageProperties.storeSelectedInItem == true && self._checkIfItemExists() == false){
        self._throwError('_create', self.C_ERROR_ITEM_DOES_NOT_EXIST, false);
      }
      
      // TO DO - handle different classic report templates
      // TO DO - handle different report types

      self.region$ = $('#'+self.reportProperties.regionId);

      self.region$.on('apexafterrefresh', function () {
        debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'After refresh processing... ');
        self._findCheckboxColumn();
        self._renderCheckboxes();
        self._addClickListeners();
        self._applySelection();
      });

      self._findCheckboxColumn();
      self._renderCheckboxes();
      self._addClickListeners();     
      self._getStoredValues();
      
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Widget initialized successfully: ');
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Report: ', self.region$);
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Header: ', self.columnHeader$);
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Cells: ' , self.columnCells$);      
    },
  
    // jQuery widget private methods

    _checkIfReportTypeSupported: function(){
      var self = this;
      debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Checking if report type is supported...');

      return self.C_SUPPORTED_REPORT_TYPES.includes(self.reportProperties.reportType);     
    },

    _checkIfItemExists: function(){
      var self = this;
      debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Checking if apex item exists...');

      return apex.item(self.storageProperties.storageItemName).node;     
    },

    _findCheckboxColumn: function(){
      var self = this;
      debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Finding checkbox column...');

      
      self.columnHeader$ = self.region$.find('th#'+self.columnProperties.columnId);
      self.columnCells$  = self.region$.find('td[headers="'+self.columnProperties.columnId+'"]');
    },

    // Function renders checkboxes available after in self.cellChecboxes$ and self.headerCheckbox$
    _renderCheckboxes: function(){
      var self = this;
      debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Rendering checkboxes...');
      
      /* ------------------------------------------------------------------- */
      /* Commented out - report can have no results in any time of a runtime */
      /*
      // Check if column to substitute is defined
      if (self.columnCells$.length == 0){
        self._throwError('_renderCheckboxes', self.C_ERROR_NO_COLUMN_FOUND, true);
        return;
      }
      */

      // rendering column checkboxes
      self.columnCells$.each(function(){
        let 
          cell$            = $(this),
          cellValue        = cell$.text(),
          valueAttribute   = ' value="'+cellValue+'" ',
          // TO DO - customizowany cb, accessibility
          checkbox$        = $('<input type="checkbox"'+ valueAttribute +'>');
          
        cell$.html(checkbox$);
      });
      self.cellChecboxes$ = self.columnCells$.find('input[type="checkbox"]');

      // rendering header checkbox
      var
        disabledAttribute  = !self.selectionProperties.allowMultipleSelection ? ' disabled ' : '',
        headerCheckbox$    = $('<input type="checkbox"'+ disabledAttribute+'>');
      
      self.columnHeader$.find('a').remove();
      self.columnHeader$.find('span').remove();
      self.columnHeader$.contents().filter(function() {
        return this.nodeType == Node.TEXT_NODE;
      }).remove();    

      self.columnHeader$.append(headerCheckbox$);
      self.headerCheckbox$ = headerCheckbox$;
    },

    _addClickListeners: function(){
      var self = this;
      debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Adding click listeners...');

      /* ------------------------------------------------------------------- */
      /* Commented out - report can have no results in any time of a runtime */
      /*
      // Check if checkboxes exist
      if (self.cellChecboxes$.length == 0){
        self._throwError('_addClickListeners', self.C_ERROR_CHECKBOXES_DO_NOT_EXIST, true);
        return;
      } 
      */

      // Add cell checkbox listeners
      self.cellChecboxes$.each(function(){
        let 
          checkbox$ = $(this),
          parentRow = $(this).closest('tr');

        if (self.selectionProperties.selectOnClickAnywhere){
          if (self.selectionProperties.allowMultipleSelection){
            parentRow.on('click', $.proxy( self._multipleSelectionHandler, self, checkbox$)); // 2 - row selection, multiple
          } else {
            parentRow.on('click', $.proxy( self._singleSelectionHandler, self, checkbox$));   // 1 - row selection, single
          } 
        } else {
          if (self.selectionProperties.allowMultipleSelection){
            checkbox$.on('click', $.proxy( self._multipleSelectionHandler, self, checkbox$));   // 3 - checkbox seleciton, single
          } else {
            checkbox$.on('click', $.proxy( self._singleSelectionHandler, self, checkbox$)); // 4 - checkbox selection, multiple   
          }
        }
      }); 
      
      // Add header checkbox listener
      if (self.selectionProperties.allowMultipleSelection){
        if (self.selectionProperties.selectOnClickAnywhere){
          self.columnHeader$.on('click', $.proxy( self._selectAllHandler, self));
        } else {
          self.headerCheckbox$.on('click', $.proxy( self._selectAllHandler, self));
        }
      }
    },

    _singleSelectionHandler: function(pCheckbox$, pEvent){
      var 
        self  = this,
        value = pCheckbox$.val();
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Single selection handler triggered by event: ', pEvent);
      

      if (self.selectedValues.includes(value)) {
        self._clearSelectedValues();
      } else {
        self._clearSelectedValues();
        self._addToSelectedValues(value);
      }

      self._applySelection();
      self._storeValues();  
    },

    _multipleSelectionHandler: function(pCheckbox$, pEvent){
      var 
        self  = this,
        value = pCheckbox$.val();
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Multiple selection handler triggered by event: ', pEvent);

      if (self.selectedValues.includes(value)) {
        self._removeFromSelectedValues(value);
      } else {
        self._addToSelectedValues(value);
      }      
      self._applySelection();
      self._storeValues(); 
    },  

    _selectAllHandler: function(pEvent){
      var self = this;
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Select all handler triggered by event: ', pEvent);  

      // if click was not in the checkbox, because checkbox will check itself
      if (!$(pEvent.target).is(self.headerCheckbox$)) {
        self.headerCheckbox$.prop('checked', !self.headerCheckbox$.prop('checked'));
      }
      if (self.headerCheckbox$.prop('checked')){
        // select all visible
        self.cellChecboxes$.each(function(){
          let 
            checbox$ = $(this),
            value    = checbox$.val();
          self._addToSelectedValues(value);
        });
      } else {
        // clear all visible
        self.cellChecboxes$.each(function(){
          let 
            checbox$ = $(this),
            value    = checbox$.val();
          self._removeFromSelectedValues(value);
        });
      }
      self._applySelection(); 
      self._storeValues();
      
    },

    _applySelection: function(){
      var self = this;
      debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Applying visual style to selected rows...');     

      // clear all cbx
      // remove selected row styles
      self.cellChecboxes$.prop('checked', false);
      self.headerCheckbox$.prop('checked', false);
      self.cellChecboxes$.closest('tr').removeClass(self.C_SELECTED_ROW_CLASS);

      // select checkboxes according to selected values array
      // add style to selected rows
      self.cellChecboxes$.each(function(){
        let 
          checkbox$ = $(this),
          value     = checkbox$.val(),
          row$      = checkbox$.closest('tr');
        if (self.selectedValues.includes(value)){
          checkbox$.prop('checked', true);
          row$.addClass(self.C_SELECTED_ROW_CLASS);
        } 
      });

      // check if header checkbox should be checked
      if (self.cellChecboxes$.length === self.cellChecboxes$.filter(":checked").length){
        self.headerCheckbox$.prop('checked', true);
      }
    },  
   
    _addToSelectedValues: function(pValue){
      var self = this;
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Adding value to currently selected rows: ', pValue);
      
      if (!self.selectedValues.includes(pValue)){
        self.selectedValues.push(pValue);
      }      
    },
    _removeFromSelectedValues: function(pValue){
      var self = this;
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Removing value from currently selected rows: ', pValue);

      self.selectedValues.splice(self.selectedValues.indexOf(pValue), 1);
    },        
    _clearSelectedValues: function(){
      var self = this;
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Clearing selected values...');

      self.selectedValues = [];           
    },    

    _getStoredValues: function(){
      var self = this;
      self.selectedValues =  []; // initialize empty array
      
      // if selection is stored in collection then try to read it
      if (self.storageProperties.storeSelectedInCollection){
        debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Restoring selected values from APEX collection...');
        let
          ajaxData = {
            "x01": "GET",
            "x03": self.storageProperties.storageCollectionName
          },
          ajaxOptions = {
            "success"                  : $.proxy(self._getStoredValuesAjaxsuccess,    self),
            "error"                    : $.proxy(self._getStoredValuesAjaxerror,      self),
            "target"                   : '#'+self.reportProperties.regionId,
            "loadingIndicator"         : '#'+self.reportProperties.regionId,
            "loadingIndicatorPosition" : "centered"
          }; 
          
        apex.server.plugin ( self.options.ajaxIdentifier, ajaxData, ajaxOptions );
        debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Restoring selected values from APEX collection...', 'Ajax sent');  
      }
      // if selection is not stored in collection, but is stored in apex item then read it
      // and apply to report
      else if (self.storageProperties.storeSelectedInItem && $v(self.storageProperties.storageItemName) != ""){
        debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Restoring selected values from APEX Item...');
        self.selectedValues = $v(self.storageProperties.storageItemName).split(self.storageProperties.valueSeparator);
        self._applySelection();
      } 
    },
    _getStoredValuesAjaxsuccess: function(pData, pTextStatus, pJqXHR){
      var self = this;
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Restoring selected values from APEX collection...', 'Ajax success', pData, pTextStatus, pJqXHR);

      self.selectedValues = pData.selectedValues.map(obj => obj.checkbox_value);
      self._applySelection();
    },
    _getStoredValuesAjaxerror: function(pJqXHR, pTextStatus, pErrorThrown){
      var self = this;
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Restoring selected values from APEX collection...', 'Ajax error', pJqXHR, pTextStatus, pErrorThrown );

      // if value can be obtained from apex item then try to do it
      if (self.storageProperties.storeSelectedInItem ){
        debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Restoring selected values from APEX Item...');
        self.selectedValues = $v(self.storageProperties.storageItemName).split(self.storageProperties.valueSeparator);
        self._applySelection();
      } 
      self._throwError('_getStoredValuesAjaxerror', self.C_ERROR_AJAX_READ_FAILURE, false);
    },

  
    _storeValues: function(){
      var self = this;

      // storing selected values in apex item 
      if (self.storageProperties.storeSelectedInItem){    
        debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Storing selected values in APEX item...');
        // if selection cannot exceed maximum length in bytes then
        // remove last selected values untill it fits
        if (self.storageProperties.limitSelection === 'Y' ){
          let 
            encoder = new TextEncoder(),
            selectionExceded = false;
          while ( encoder.encode( self.selectedValues.join(self.storageProperties.valueSeparator) ).length > self.C_STORAGE_ITEM_MAX_BYTES_COUNT ){
            self.selectedValues.pop();
            selectionExceded = true;
          }
          if (selectionExceded){
            debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Limiting selection length to maximum number of bytes ', self.C_STORAGE_ITEM_MAX_BYTES_COUNT);
            apex.event.trigger(self.region$, self.C_EVENT_MAX_SELECTION_EXCEDED);
            self._applySelection();
          }          
          $s(self.storageProperties.storageItemName, self.selectedValues.join(self.storageProperties.valueSeparator) );
          debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Selected values stored in APEX item successfully');
        } 
        
        // if sellection is not limited then write it to the apex item
        else {
          $s(self.storageProperties.storageItemName, self.selectedValues.join(self.storageProperties.valueSeparator) );
          debug.message(self.C_LOG_LVL_6, self.C_LOG_PREFIX, 'Selected values stored in APEX item successfully');
        }        
      }

      // storing selected values in apex collection
      if (self.storageProperties.storeSelectedInCollection || self.storageProperties.itemAutoSubmit){
        debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Saving selected values to APEX session state (item/collection)...');
        let
          ajaxData = {
            "x01": self.storageProperties.storeSelectedInCollection ? "SET" : "SUBMIT",
            "x02": self.storageProperties.storeSelectedInCollection,
            "x03": self.storageProperties.storageCollectionName,
            "f01": self.selectedValues
          },
          ajaxOptions = {
            "success"    : $.proxy(self._storeValuesAjaxsuccess,    self),
            "error"      : $.proxy(self._storeValuesAjaxerror,      self)
          }; 
        if (self.storageProperties.itemAutoSubmit){
          ajaxData.pageItems = [self.storageProperties.storageItemName];
        }
        apex.server.plugin ( self.options.ajaxIdentifier, ajaxData, ajaxOptions );
        debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Saving selected values to APEX session state (item/collection)...', 'Ajax sent'); 
      }
    },    

    _storeValuesAjaxsuccess: function(pData, pTextStatus, pJqXHR){
      var self = this;
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Saving selected values to APEX session state (item/collection)...', 'Ajax success', pData, pTextStatus, pJqXHR);
    },
    _storeValuesAjaxerror: function(pJqXHR, pTextStatus, pErrorThrown){
      var self = this;
      debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Saving selected values to APEX session state (item/collection)...', 'Ajax error', pJqXHR, pTextStatus, pErrorThrown );

      self._throwError('_storeValuesAjaxerror', self.C_ERROR_AJAX_STORE_FAILURE, false);
    },

    _throwError: function(pFunctionName, pErrorMessage, pStopPlugin, pDisplayPageErrorMessages){
      var 
        self = this,
        displayPageErrorMessages = pDisplayPageErrorMessages || self.C_DISPLAY_PAGE_ERROR_MESSAGES,
        endUserErrorMessage = self.C_END_USER_ERROR_PREFIX + pErrorMessage + self.C_END_USER_ERROR_SUFFIX;
      
      debug.message(self.C_LOG_LVL_ERROR, self.C_LOG_PREFIX, pFunctionName, pErrorMessage);
      
      if (displayPageErrorMessages){
        apex.message.clearErrors();
        apex.message.showErrors({
          type:       "error",
          location:   "page",
          message:    endUserErrorMessage,
          unsafe:     false
        });
      }
      if (pStopPlugin){
        throw new Error(endUserErrorMessage);
      }
    },

  // jQuery widget public methods 

  clearSelection: function(){
    var self = this;
    debug.message(self.C_LOG_LVL_DEBUG, self.C_LOG_PREFIX, 'Clear selection public method invoked...'); 
    
    self._clearSelectedValues();
    self._applySelection();
    self._storeValues();
  },
  // jQuery widget native methods
  _destroy: function(){
  },

  // options: function( pOptions ){
  //   this._super( pOptions );
  // },
  _setOption: function( pKey, pValue ) {
    if ( pKey === "value" ) {
      pValue = this._constrain( pValue );
    }
    this._super( pKey, pValue );
  },  
  _setOptions: function( pOptions ) {
    this._super( pOptions );
  },    
  
  });
 })(apex.debug, apex.jQuery );
