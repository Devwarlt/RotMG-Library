package com.company.assembleegameclient.mapeditor
{
   import com.company.assembleegameclient.account.ui.CheckBoxField;
   import com.company.assembleegameclient.account.ui.TextInputField;
   import com.company.assembleegameclient.editor.CommandEvent;
   import com.company.assembleegameclient.editor.CommandList;
   import com.company.assembleegameclient.editor.CommandQueue;
   import com.company.assembleegameclient.map.GroundLibrary;
   import com.company.assembleegameclient.map.RegionLibrary;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.screens.TitleMenuOption;
   import com.company.assembleegameclient.ui.DeprecatedClickableText;
   import com.company.assembleegameclient.ui.dropdown.DropDown;
   import com.company.util.IntPoint;
   import com.company.util.SpriteUtil;
   import com.hurlant.util.Base64;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.text.TextFieldAutoSize;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import kabam.lib.json.JsonParser;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.core.model.PlayerModel;
   import kabam.rotmg.ui.view.components.ScreenBase;
   import net.hires.debug.Stats;
   
   public class EditingScreen extends Sprite
   {
      
      private static const MAP_Y:int = 600 - MEMap.SIZE - 10;
      
      public static const stats_:Stats = new Stats();
       
      
      public var commandMenu_:MECommandMenu;
      
      private var commandQueue_:CommandQueue;
      
      public var meMap_:MEMap;
      
      public var infoPane_:InfoPane;
      
      public var chooserDropDown_:DropDown;
      
      public var mapSizeDropDown_:DropDown;
      
      public var choosers_:Dictionary;
      
      public var groundChooser_:GroundChooser;
      
      public var objChooser_:ObjectChooser;
      
      public var enemyChooser_:EnemyChooser;
      
      public var object3DChooser_:Object3DChooser;
      
      public var wallChooser_:WallChooser;
      
      public var allObjChooser_:AllObjectChooser;
      
      public var allGameObjChooser_:AllObjectChooser;
      
      public var regionChooser_:RegionChooser;
      
      public var dungeonChooser_:DungeonChooser;
      
      public var search:TextInputField;
      
      public var filter:Filter;
      
      public var returnButton_:TitleMenuOption;
      
      public var chooser_:Chooser;
      
      public var filename_:String = null;
      
      public var checkBoxArray:Array;
      
      public var showAllBtn:DeprecatedClickableText;
      
      public var hideAllBtn:DeprecatedClickableText;
      
      private var json:JsonParser;
      
      private var pickObjHolder:Sprite;
      
      private var tilesBackup:Vector.<METile>;
      
      private var loadedFile_:FileReference = null;
      
      public function EditingScreen()
      {
         var _loc2_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:Vector.<String> = null;
         super();
         addChild(new ScreenBase());
         this.json = StaticInjectorContext.getInjector().getInstance(JsonParser);
         this.commandMenu_ = new MECommandMenu();
         this.commandMenu_.x = 15;
         this.commandMenu_.y = MAP_Y - 60;
         this.commandMenu_.addEventListener(CommandEvent.UNDO_COMMAND_EVENT,this.onUndo);
         this.commandMenu_.addEventListener(CommandEvent.REDO_COMMAND_EVENT,this.onRedo);
         this.commandMenu_.addEventListener(CommandEvent.CLEAR_COMMAND_EVENT,this.onClear);
         this.commandMenu_.addEventListener(CommandEvent.LOAD_COMMAND_EVENT,this.onLoad);
         this.commandMenu_.addEventListener(CommandEvent.SAVE_COMMAND_EVENT,this.onSave);
         this.commandMenu_.addEventListener(CommandEvent.SUBMIT_COMMAND_EVENT,this.onSubmit);
         this.commandMenu_.addEventListener(CommandEvent.TEST_COMMAND_EVENT,this.onTest);
         this.commandMenu_.addEventListener(CommandEvent.SELECT_COMMAND_EVENT,this.onMenuSelect);
         addChild(this.commandMenu_);
         this.commandQueue_ = new CommandQueue();
         this.meMap_ = new MEMap();
         this.meMap_.addEventListener(TilesEvent.TILES_EVENT,this.onTilesEvent);
         this.meMap_.x = 800 / 2 - MEMap.SIZE / 2;
         this.meMap_.y = MAP_Y;
         addChild(this.meMap_);
         this.infoPane_ = new InfoPane(this.meMap_);
         this.infoPane_.x = 4;
         this.infoPane_.y = 600 - InfoPane.HEIGHT - 10;
         addChild(this.infoPane_);
         var _loc1_:PlayerModel = StaticInjectorContext.getInjector().getInstance(PlayerModel);
         _loc2_ = _loc1_.isAdmin();
         if(_loc2_)
         {
            this.chooserDropDown_ = new DropDown(GroupDivider.GROUP_LABELS,Chooser.WIDTH,26);
         }
         else
         {
            _loc6_ = GroupDivider.GROUP_LABELS.concat();
            _loc6_.splice(_loc6_.indexOf("All Game Objects"),1);
            this.chooserDropDown_ = new DropDown(_loc6_,Chooser.WIDTH,26);
         }
         addChild(this.chooserDropDown_);
         this.chooserDropDown_.x = this.meMap_.x + MEMap.SIZE + 4;
         this.chooserDropDown_.y = MAP_Y - this.chooserDropDown_.height - 4;
         this.chooserDropDown_.addEventListener(Event.CHANGE,this.onDropDownChange);
         var _loc3_:Vector.<String> = new Vector.<String>(0);
         var _loc4_:Number = MEMap.MAX_ALLOWED_SQUARES;
         while(_loc4_ >= 64)
         {
            _loc3_.push(_loc4_ + "x" + _loc4_);
            _loc4_ = _loc4_ / 2;
         }
         this.mapSizeDropDown_ = new DropDown(_loc3_,Chooser.WIDTH,26);
         this.mapSizeDropDown_.setValue(MEMap.NUM_SQUARES + "x" + MEMap.NUM_SQUARES);
         this.mapSizeDropDown_.x = this.chooserDropDown_.x - this.chooserDropDown_.width - 4;
         this.mapSizeDropDown_.y = this.chooserDropDown_.y;
         this.mapSizeDropDown_.addEventListener(Event.CHANGE,this.onDropDownSizeChange);
         addChild(this.mapSizeDropDown_);
         this.createCheckboxes();
         this.filter = new Filter();
         this.filter.x = this.meMap_.x + MEMap.SIZE + 4;
         this.filter.y = MAP_Y;
         addChild(this.filter);
         this.filter.addEventListener(Event.CHANGE,this.onFilterChange);
         this.filter.enableDropDownFilter(true);
         this.filter.enableValueFilter(false);
         this.returnButton_ = new TitleMenuOption("Screens.back",18,false);
         this.returnButton_.setAutoSize(TextFieldAutoSize.RIGHT);
         this.returnButton_.x = this.chooserDropDown_.x + this.chooserDropDown_.width - 7;
         this.returnButton_.y = 2;
         addChild(this.returnButton_);
         GroupDivider.divideObjects();
         this.choosers_ = new Dictionary(true);
         _loc5_ = MAP_Y + this.mapSizeDropDown_.height + 50;
         this.groundChooser_ = new GroundChooser();
         this.groundChooser_.x = this.chooserDropDown_.x;
         this.groundChooser_.y = _loc5_;
         this.choosers_[GroupDivider.GROUP_LABELS[0]] = this.groundChooser_;
         this.objChooser_ = new ObjectChooser();
         this.objChooser_.x = this.chooserDropDown_.x;
         this.objChooser_.y = _loc5_;
         this.choosers_[GroupDivider.GROUP_LABELS[1]] = this.objChooser_;
         this.enemyChooser_ = new EnemyChooser();
         this.enemyChooser_.x = this.chooserDropDown_.x;
         this.enemyChooser_.y = _loc5_;
         this.choosers_[GroupDivider.GROUP_LABELS[2]] = this.enemyChooser_;
         this.wallChooser_ = new WallChooser();
         this.wallChooser_.x = this.chooserDropDown_.x;
         this.wallChooser_.y = _loc5_;
         this.choosers_[GroupDivider.GROUP_LABELS[3]] = this.wallChooser_;
         this.object3DChooser_ = new Object3DChooser();
         this.object3DChooser_.x = this.chooserDropDown_.x;
         this.object3DChooser_.y = _loc5_;
         this.choosers_[GroupDivider.GROUP_LABELS[4]] = this.object3DChooser_;
         this.allObjChooser_ = new AllObjectChooser();
         this.allObjChooser_.x = this.chooserDropDown_.x;
         this.allObjChooser_.y = _loc5_;
         this.choosers_[GroupDivider.GROUP_LABELS[5]] = this.allObjChooser_;
         this.regionChooser_ = new RegionChooser();
         this.regionChooser_.x = this.chooserDropDown_.x;
         this.regionChooser_.y = _loc5_;
         this.choosers_[GroupDivider.GROUP_LABELS[6]] = this.regionChooser_;
         this.dungeonChooser_ = new DungeonChooser();
         this.dungeonChooser_.x = this.chooserDropDown_.x;
         this.dungeonChooser_.y = _loc5_;
         this.choosers_[GroupDivider.GROUP_LABELS[7]] = this.dungeonChooser_;
         if(_loc2_)
         {
            this.allGameObjChooser_ = new AllObjectChooser("","All Game Objects");
            this.allGameObjChooser_.x = this.chooserDropDown_.x;
            this.allGameObjChooser_.y = _loc5_;
            this.choosers_[GroupDivider.GROUP_LABELS[8]] = this.allGameObjChooser_;
         }
         this.chooser_ = this.groundChooser_;
         addChild(this.groundChooser_);
         this.chooserDropDown_.setIndex(0);
      }
      
      private function createCheckboxes() : void
      {
         this.checkBoxArray = new Array();
         var _loc1_:* = new DeprecatedClickableText(14,true,"(Show All)");
         _loc1_.buttonMode = true;
         _loc1_.x = this.mapSizeDropDown_.x - 380;
         _loc1_.y = this.mapSizeDropDown_.y - 20;
         _loc1_.setAutoSize(TextFieldAutoSize.LEFT);
         _loc1_.addEventListener(MouseEvent.CLICK,this.onCheckBoxUpdated);
         addChild(_loc1_);
         var _loc2_:CheckBoxField = new CheckBoxField("Objects",true);
         _loc2_.x = _loc1_.x + 80;
         _loc2_.y = this.mapSizeDropDown_.y - 20;
         _loc2_.scaleX = _loc2_.scaleY = 0.8;
         _loc2_.addEventListener(MouseEvent.CLICK,this.onCheckBoxUpdated);
         addChild(_loc2_);
         var _loc3_:* = new DeprecatedClickableText(14,true,"(Hide All)");
         _loc3_.buttonMode = true;
         _loc3_.x = this.mapSizeDropDown_.x - 380;
         _loc3_.y = this.mapSizeDropDown_.y + 8;
         _loc3_.setAutoSize(TextFieldAutoSize.LEFT);
         _loc3_.addEventListener(MouseEvent.CLICK,this.onCheckBoxUpdated);
         addChild(_loc3_);
         var _loc4_:CheckBoxField = new CheckBoxField("Regions",true);
         _loc4_.x = _loc1_.x + 80;
         _loc4_.y = this.mapSizeDropDown_.y + 8;
         _loc4_.scaleX = _loc4_.scaleY = 0.8;
         _loc4_.addEventListener(MouseEvent.CLICK,this.onCheckBoxUpdated);
         addChild(_loc4_);
         this.checkBoxArray.push(_loc1_);
         this.checkBoxArray.push(_loc2_);
         this.checkBoxArray.push(_loc4_);
         this.checkBoxArray.push(_loc3_);
      }
      
      private function setSearch(param1:String) : void
      {
         this.filter.removeEventListener(Event.CHANGE,this.onFilterChange);
         this.filter.setSearch(param1);
         this.filter.addEventListener(Event.CHANGE,this.onFilterChange);
      }
      
      private function onFilterChange(param1:Event) : void
      {
         switch(this.chooser_)
         {
            case this.groundChooser_:
               this.groundChooser_.reloadObjects(this.filter.searchStr,this.filter.filterType);
               break;
            case this.objChooser_:
               this.objChooser_.reloadObjects(this.filter.searchStr);
               break;
            case this.enemyChooser_:
               this.enemyChooser_.reloadObjects(this.filter.searchStr,this.filter.filterType,this.filter.minValue,this.filter.maxValue);
               break;
            case this.wallChooser_:
               this.wallChooser_.reloadObjects(this.filter.searchStr);
               break;
            case this.object3DChooser_:
               this.object3DChooser_.reloadObjects(this.filter.searchStr);
               break;
            case this.allObjChooser_:
               this.allObjChooser_.reloadObjects(this.filter.searchStr);
               break;
            case this.allGameObjChooser_:
               this.allGameObjChooser_.reloadObjects(this.filter.searchStr,false,"All Game Objects");
               break;
            case this.regionChooser_:
               break;
            case this.dungeonChooser_:
               this.dungeonChooser_.reloadObjects(this.filter.dungeon,this.filter.searchStr);
         }
      }
      
      private function onCheckBoxUpdated(param1:MouseEvent) : void
      {
         var _loc2_:CheckBoxField = null;
         switch(param1.currentTarget)
         {
            case this.checkBoxArray[0]:
               this.meMap_.ifShowGroundLayer = true;
               this.meMap_.ifShowObjectLayer = true;
               this.meMap_.ifShowRegionLayer = true;
               (this.checkBoxArray[Layer.OBJECT] as CheckBoxField).setChecked();
               (this.checkBoxArray[Layer.REGION] as CheckBoxField).setChecked();
               break;
            case this.checkBoxArray[Layer.OBJECT]:
               _loc2_ = param1.currentTarget as CheckBoxField;
               this.meMap_.ifShowObjectLayer = _loc2_.isChecked();
               break;
            case this.checkBoxArray[Layer.REGION]:
               _loc2_ = param1.currentTarget as CheckBoxField;
               this.meMap_.ifShowRegionLayer = _loc2_.isChecked();
               break;
            case this.checkBoxArray[3]:
               this.meMap_.ifShowGroundLayer = false;
               this.meMap_.ifShowObjectLayer = false;
               this.meMap_.ifShowRegionLayer = false;
               (this.checkBoxArray[Layer.OBJECT] as CheckBoxField).setUnchecked();
               (this.checkBoxArray[Layer.REGION] as CheckBoxField).setUnchecked();
         }
         this.meMap_.draw();
      }
      
      private function onTilesEvent(param1:TilesEvent) : void
      {
         var _loc2_:IntPoint = null;
         var _loc3_:METile = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:EditTileProperties = null;
         var _loc8_:Vector.<METile> = null;
         var _loc9_:Bitmap = null;
         var _loc10_:uint = 0;
         _loc2_ = param1.tiles_[0];
         switch(this.commandMenu_.getCommand())
         {
            case MECommandMenu.DRAW_COMMAND:
               this.addModifyCommandList(param1.tiles_,this.chooser_.layer_,this.chooser_.selectedType());
               break;
            case MECommandMenu.ERASE_COMMAND:
               this.addModifyCommandList(param1.tiles_,this.chooser_.layer_,-1);
               break;
            case MECommandMenu.SAMPLE_COMMAND:
               _loc4_ = this.meMap_.getType(_loc2_.x_,_loc2_.y_,this.chooser_.layer_);
               if(_loc4_ == -1)
               {
                  return;
               }
               _loc5_ = GroupDivider.getCategoryByType(_loc4_,this.chooser_.layer_);
               if(_loc5_ == "")
               {
                  break;
               }
               this.chooser_ = this.choosers_[_loc5_];
               this.chooserDropDown_.setValue(_loc5_);
               this.chooser_.setSelectedType(_loc4_);
               this.commandMenu_.setCommand(MECommandMenu.DRAW_COMMAND);
               break;
            case MECommandMenu.EDIT_COMMAND:
               _loc6_ = this.meMap_.getObjectName(_loc2_.x_,_loc2_.y_);
               _loc7_ = new EditTileProperties(param1.tiles_,_loc6_);
               _loc7_.addEventListener(Event.COMPLETE,this.onEditComplete);
               addChild(_loc7_);
               break;
            case MECommandMenu.CUT_COMMAND:
               this.tilesBackup = new Vector.<METile>();
               _loc8_ = new Vector.<METile>();
               for each(_loc2_ in param1.tiles_)
               {
                  _loc3_ = this.meMap_.getTile(_loc2_.x_,_loc2_.y_);
                  if(_loc3_ != null)
                  {
                     _loc3_ = _loc3_.clone();
                  }
                  this.tilesBackup.push(_loc3_);
                  _loc8_.push(null);
               }
               this.addPasteCommandList(param1.tiles_,_loc8_);
               this.meMap_.freezeSelect();
               this.commandMenu_.setCommand(MECommandMenu.PASTE_COMMAND);
               break;
            case MECommandMenu.COPY_COMMAND:
               this.tilesBackup = new Vector.<METile>();
               for each(_loc2_ in param1.tiles_)
               {
                  _loc3_ = this.meMap_.getTile(_loc2_.x_,_loc2_.y_);
                  if(_loc3_ != null)
                  {
                     _loc3_ = _loc3_.clone();
                  }
                  this.tilesBackup.push(_loc3_);
               }
               this.meMap_.freezeSelect();
               this.commandMenu_.setCommand(MECommandMenu.PASTE_COMMAND);
               break;
            case MECommandMenu.PASTE_COMMAND:
               this.addPasteCommandList(param1.tiles_,this.tilesBackup);
               break;
            case MECommandMenu.PICK_UP_COMMAND:
               _loc3_ = this.meMap_.getTile(_loc2_.x_,_loc2_.y_);
               if(_loc3_ != null && _loc3_.types_[Layer.OBJECT] != -1)
               {
                  _loc9_ = new Bitmap(ObjectLibrary.getTextureFromType(_loc3_.types_[Layer.OBJECT]));
                  this.pickObjHolder = new Sprite();
                  this.pickObjHolder.addChild(_loc9_);
                  this.pickObjHolder.startDrag();
                  this.pickObjHolder.name = String(_loc3_.types_[Layer.OBJECT]);
                  this.addModifyCommandList(param1.tiles_,Layer.OBJECT,-1);
                  this.commandMenu_.setCommand(MECommandMenu.DROP_COMMAND);
               }
               break;
            case MECommandMenu.DROP_COMMAND:
               if(this.pickObjHolder != null)
               {
                  _loc10_ = int(this.pickObjHolder.name);
                  this.addModifyCommandList(param1.tiles_,Layer.OBJECT,_loc10_);
                  this.pickObjHolder.stopDrag();
                  this.pickObjHolder.removeChildAt(0);
                  this.pickObjHolder = null;
                  this.commandMenu_.setCommand(MECommandMenu.PICK_UP_COMMAND);
               }
         }
         this.meMap_.draw();
      }
      
      private function onEditComplete(param1:Event) : void
      {
         var _loc2_:EditTileProperties = param1.currentTarget as EditTileProperties;
         this.addObjectNameCommandList(_loc2_.tiles_,_loc2_.getObjectName());
      }
      
      private function addModifyCommandList(param1:Vector.<IntPoint>, param2:int, param3:int) : void
      {
         var _loc5_:IntPoint = null;
         var _loc6_:int = 0;
         var _loc4_:CommandList = new CommandList();
         for each(_loc5_ in param1)
         {
            _loc6_ = this.meMap_.getType(_loc5_.x_,_loc5_.y_,param2);
            if(_loc6_ != param3)
            {
               _loc4_.addCommand(new MEModifyCommand(this.meMap_,_loc5_.x_,_loc5_.y_,param2,_loc6_,param3));
            }
         }
         if(_loc4_.empty())
         {
            return;
         }
         this.commandQueue_.addCommandList(_loc4_);
      }
      
      private function addPasteCommandList(param1:Vector.<IntPoint>, param2:Vector.<METile>) : void
      {
         var _loc5_:IntPoint = null;
         var _loc6_:METile = null;
         var _loc3_:CommandList = new CommandList();
         var _loc4_:int = 0;
         for each(_loc5_ in param1)
         {
            if(_loc4_ >= param2.length)
            {
               break;
            }
            _loc6_ = this.meMap_.getTile(_loc5_.x_,_loc5_.y_);
            _loc3_.addCommand(new MEReplaceCommand(this.meMap_,_loc5_.x_,_loc5_.y_,_loc6_,param2[_loc4_]));
            _loc4_++;
         }
         if(_loc3_.empty())
         {
            return;
         }
         this.commandQueue_.addCommandList(_loc3_);
      }
      
      private function addObjectNameCommandList(param1:Vector.<IntPoint>, param2:String) : void
      {
         var _loc4_:IntPoint = null;
         var _loc5_:String = null;
         var _loc3_:CommandList = new CommandList();
         for each(_loc4_ in param1)
         {
            _loc5_ = this.meMap_.getObjectName(_loc4_.x_,_loc4_.y_);
            if(_loc5_ != param2)
            {
               _loc3_.addCommand(new MEObjectNameCommand(this.meMap_,_loc4_.x_,_loc4_.y_,_loc5_,param2));
            }
         }
         if(_loc3_.empty())
         {
            return;
         }
         this.commandQueue_.addCommandList(_loc3_);
      }
      
      private function safeRemoveCategoryChildren() : *
      {
         SpriteUtil.safeRemoveChild(this,this.groundChooser_);
         SpriteUtil.safeRemoveChild(this,this.objChooser_);
         SpriteUtil.safeRemoveChild(this,this.enemyChooser_);
         SpriteUtil.safeRemoveChild(this,this.regionChooser_);
         SpriteUtil.safeRemoveChild(this,this.wallChooser_);
         SpriteUtil.safeRemoveChild(this,this.object3DChooser_);
         SpriteUtil.safeRemoveChild(this,this.allObjChooser_);
         SpriteUtil.safeRemoveChild(this,this.allGameObjChooser_);
         SpriteUtil.safeRemoveChild(this,this.dungeonChooser_);
      }
      
      private function onDropDownChange(param1:Event = null) : void
      {
         switch(this.chooserDropDown_.getValue())
         {
            case GroundLibrary.GROUND_CATEGORY:
               this.setSearch(this.groundChooser_.getLastSearch());
               this.safeRemoveCategoryChildren();
               SpriteUtil.safeAddChild(this,this.groundChooser_);
               this.chooser_ = this.groundChooser_;
               this.filter.setFilterType(ObjectLibrary.TILE_FILTER_LIST);
               this.filter.enableDropDownFilter(true);
               this.filter.enableValueFilter(false);
               this.filter.enableDungeonFilter(false);
               break;
            case "Basic Objects":
               this.setSearch(this.objChooser_.getLastSearch());
               this.safeRemoveCategoryChildren();
               SpriteUtil.safeAddChild(this,this.objChooser_);
               this.chooser_ = this.objChooser_;
               this.filter.enableDropDownFilter(false);
               this.filter.enableValueFilter(false);
               this.filter.enableDungeonFilter(false);
               break;
            case "Enemies":
               this.setSearch(this.enemyChooser_.getLastSearch());
               this.safeRemoveCategoryChildren();
               SpriteUtil.safeAddChild(this,this.enemyChooser_);
               this.chooser_ = this.enemyChooser_;
               this.filter.setFilterType(ObjectLibrary.ENEMY_FILTER_LIST);
               this.filter.enableDropDownFilter(true);
               this.filter.enableValueFilter(true);
               this.filter.enableDungeonFilter(false);
               break;
            case "Regions":
               this.setSearch("");
               this.safeRemoveCategoryChildren();
               SpriteUtil.safeAddChild(this,this.regionChooser_);
               this.chooser_ = this.regionChooser_;
               this.filter.enableDropDownFilter(false);
               this.filter.enableValueFilter(false);
               this.filter.enableDungeonFilter(false);
               break;
            case "Walls":
               this.setSearch(this.wallChooser_.getLastSearch());
               this.safeRemoveCategoryChildren();
               SpriteUtil.safeAddChild(this,this.wallChooser_);
               this.chooser_ = this.wallChooser_;
               this.filter.enableDropDownFilter(false);
               this.filter.enableValueFilter(false);
               this.filter.enableDungeonFilter(false);
               break;
            case "3D Objects":
               this.setSearch(this.object3DChooser_.getLastSearch());
               this.safeRemoveCategoryChildren();
               SpriteUtil.safeAddChild(this,this.object3DChooser_);
               this.chooser_ = this.object3DChooser_;
               this.filter.enableDropDownFilter(false);
               this.filter.enableValueFilter(false);
               this.filter.enableDungeonFilter(false);
               break;
            case "All Map Objects":
               this.setSearch(this.allObjChooser_.getLastSearch());
               this.safeRemoveCategoryChildren();
               SpriteUtil.safeAddChild(this,this.allObjChooser_);
               this.chooser_ = this.allObjChooser_;
               this.filter.enableDropDownFilter(false);
               this.filter.enableValueFilter(false);
               break;
            case "All Game Objects":
               this.setSearch(this.allGameObjChooser_.getLastSearch());
               this.safeRemoveCategoryChildren();
               SpriteUtil.safeAddChild(this,this.allGameObjChooser_);
               this.chooser_ = this.allGameObjChooser_;
               this.filter.enableDropDownFilter(false);
               this.filter.enableValueFilter(false);
               break;
            case "Dungeons":
               this.setSearch(this.dungeonChooser_.getLastSearch());
               this.safeRemoveCategoryChildren();
               SpriteUtil.safeAddChild(this,this.dungeonChooser_);
               this.chooser_ = this.dungeonChooser_;
               this.filter.enableDropDownFilter(false);
               this.filter.enableValueFilter(false);
               this.filter.enableDungeonFilter(true);
         }
      }
      
      private function onDropDownSizeChange(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         switch(this.mapSizeDropDown_.getValue())
         {
            case "64x64":
               _loc2_ = 64;
               break;
            case "128x128":
               _loc2_ = 128;
               break;
            case "256x256":
               _loc2_ = 256;
               break;
            case "512x512":
               _loc2_ = 512;
               break;
            case "1024x1024":
               _loc2_ = 1024;
         }
         this.meMap_.resize(_loc2_);
         this.meMap_.draw();
      }
      
      private function onUndo(param1:CommandEvent) : void
      {
         this.commandQueue_.undo();
         this.meMap_.draw();
      }
      
      private function onRedo(param1:CommandEvent) : void
      {
         this.commandQueue_.redo();
         this.meMap_.draw();
      }
      
      private function onClear(param1:CommandEvent) : void
      {
         var _loc4_:IntPoint = null;
         var _loc5_:METile = null;
         var _loc2_:Vector.<IntPoint> = this.meMap_.getAllTiles();
         var _loc3_:CommandList = new CommandList();
         for each(_loc4_ in _loc2_)
         {
            _loc5_ = this.meMap_.getTile(_loc4_.x_,_loc4_.y_);
            if(_loc5_ != null)
            {
               _loc3_.addCommand(new MEClearCommand(this.meMap_,_loc4_.x_,_loc4_.y_,_loc5_));
            }
         }
         if(_loc3_.empty())
         {
            return;
         }
         this.commandQueue_.addCommandList(_loc3_);
         this.meMap_.draw();
         this.filename_ = null;
      }
      
      private function createMapJSON() : String
      {
         var _loc7_:int = 0;
         var _loc8_:METile = null;
         var _loc9_:Object = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc1_:Rectangle = this.meMap_.getTileBounds();
         if(_loc1_ == null)
         {
            return null;
         }
         var _loc2_:Object = {};
         _loc2_["width"] = int(_loc1_.width);
         _loc2_["height"] = int(_loc1_.height);
         var _loc3_:Object = {};
         var _loc4_:Array = [];
         var _loc5_:ByteArray = new ByteArray();
         var _loc6_:int = _loc1_.y;
         while(_loc6_ < _loc1_.bottom)
         {
            _loc7_ = _loc1_.x;
            while(_loc7_ < _loc1_.right)
            {
               _loc8_ = this.meMap_.getTile(_loc7_,_loc6_);
               _loc9_ = this.getEntry(_loc8_);
               _loc10_ = this.json.stringify(_loc9_);
               if(!_loc3_.hasOwnProperty(_loc10_))
               {
                  _loc11_ = _loc4_.length;
                  _loc3_[_loc10_] = _loc11_;
                  _loc4_.push(_loc9_);
               }
               else
               {
                  _loc11_ = _loc3_[_loc10_];
               }
               _loc5_.writeShort(_loc11_);
               _loc7_++;
            }
            _loc6_++;
         }
         _loc2_["dict"] = _loc4_;
         _loc5_.compress();
         _loc2_["data"] = Base64.encodeByteArray(_loc5_);
         return this.json.stringify(_loc2_);
      }
      
      private function onSave(param1:CommandEvent) : void
      {
         var _loc2_:String = this.createMapJSON();
         if(_loc2_ == null)
         {
            return;
         }
         new FileReference().save(_loc2_,this.filename_ == null?"map.jm":this.filename_);
      }
      
      private function onSubmit(param1:CommandEvent) : void
      {
         var _loc2_:String = this.createMapJSON();
         if(_loc2_ == null)
         {
            return;
         }
         this.meMap_.setMinZoom();
         this.meMap_.draw();
         dispatchEvent(new SubmitJMEvent(_loc2_,this.meMap_.getMapStatistics()));
      }
      
      private function getEntry(param1:METile) : Object
      {
         var _loc3_:Vector.<int> = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc2_:Object = {};
         if(param1 != null)
         {
            _loc3_ = param1.types_;
            if(_loc3_[Layer.GROUND] != -1)
            {
               _loc4_ = GroundLibrary.getIdFromType(_loc3_[Layer.GROUND]);
               _loc2_["ground"] = _loc4_;
            }
            if(_loc3_[Layer.OBJECT] != -1)
            {
               _loc4_ = ObjectLibrary.getIdFromType(_loc3_[Layer.OBJECT]);
               _loc5_ = {"id":_loc4_};
               if(param1.objName_ != null)
               {
                  _loc5_["name"] = param1.objName_;
               }
               _loc2_["objs"] = [_loc5_];
            }
            if(_loc3_[Layer.REGION] != -1)
            {
               _loc4_ = RegionLibrary.getIdFromType(_loc3_[Layer.REGION]);
               _loc2_["regions"] = [{"id":_loc4_}];
            }
         }
         return _loc2_;
      }
      
      private function onLoad(param1:CommandEvent) : void
      {
         this.loadedFile_ = new FileReference();
         this.loadedFile_.addEventListener(Event.SELECT,this.onFileBrowseSelect);
         this.loadedFile_.browse([new FileFilter("JSON Map (*.jm)","*.jm")]);
      }
      
      private function onFileBrowseSelect(param1:Event) : void
      {
         var event:Event = param1;
         var loadedFile:FileReference = event.target as FileReference;
         loadedFile.addEventListener(Event.COMPLETE,this.onFileLoadComplete);
         loadedFile.addEventListener(IOErrorEvent.IO_ERROR,this.onFileLoadIOError);
         try
         {
            loadedFile.load();
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      private function onFileLoadComplete(param1:Event) : void
      {
         var _loc7_:String = null;
         var _loc11_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Object = null;
         var _loc15_:Array = null;
         var _loc16_:Array = null;
         var _loc17_:Object = null;
         var _loc18_:Object = null;
         var _loc2_:FileReference = param1.target as FileReference;
         this.filename_ = _loc2_.name;
         var _loc3_:Object = this.json.parse(_loc2_.data.toString());
         var _loc4_:int = _loc3_["width"];
         var _loc5_:int = _loc3_["height"];
         var _loc6_:Number = 64;
         while(_loc6_ < _loc3_["width"] || _loc6_ < _loc3_["height"])
         {
            _loc6_ = _loc6_ * 2;
         }
         if(MEMap.NUM_SQUARES != _loc6_)
         {
            _loc7_ = _loc6_ + "x" + _loc6_;
            if(!this.mapSizeDropDown_.setValue(_loc7_))
            {
               this.mapSizeDropDown_.setValue("512x512");
            }
         }
         var _loc8_:Rectangle = new Rectangle(int(MEMap.NUM_SQUARES / 2 - _loc4_ / 2),int(MEMap.NUM_SQUARES / 2 - _loc5_ / 2),_loc4_,_loc5_);
         this.meMap_.clear();
         this.commandQueue_.clear();
         var _loc9_:Array = _loc3_["dict"];
         var _loc10_:ByteArray = Base64.decodeToByteArray(_loc3_["data"]);
         _loc10_.uncompress();
         var _loc12_:int = _loc8_.y;
         while(_loc12_ < _loc8_.bottom)
         {
            _loc13_ = _loc8_.x;
            while(_loc13_ < _loc8_.right)
            {
               _loc14_ = _loc9_[_loc10_.readShort()];
               if(_loc14_.hasOwnProperty("ground"))
               {
                  _loc11_ = GroundLibrary.idToType_[_loc14_["ground"]];
                  this.meMap_.modifyTile(_loc13_,_loc12_,Layer.GROUND,_loc11_);
               }
               _loc15_ = _loc14_["objs"];
               if(_loc15_ != null)
               {
                  for each(_loc17_ in _loc15_)
                  {
                     if(ObjectLibrary.idToType_.hasOwnProperty(_loc17_["id"]))
                     {
                        _loc11_ = ObjectLibrary.idToType_[_loc17_["id"]];
                        this.meMap_.modifyTile(_loc13_,_loc12_,Layer.OBJECT,_loc11_);
                        if(_loc17_.hasOwnProperty("name"))
                        {
                           this.meMap_.modifyObjectName(_loc13_,_loc12_,_loc17_["name"]);
                        }
                     }
                  }
               }
               _loc16_ = _loc14_["regions"];
               if(_loc16_ != null)
               {
                  for each(_loc18_ in _loc16_)
                  {
                     _loc11_ = RegionLibrary.idToType_[_loc18_["id"]];
                     this.meMap_.modifyTile(_loc13_,_loc12_,Layer.REGION,_loc11_);
                  }
               }
               _loc13_++;
            }
            _loc12_++;
         }
         this.meMap_.draw();
      }
      
      public function disableInput() : void
      {
         removeChild(this.commandMenu_);
      }
      
      public function enableInput() : void
      {
         addChild(this.commandMenu_);
      }
      
      private function onFileLoadIOError(param1:Event) : void
      {
      }
      
      private function onTest(param1:Event) : void
      {
         dispatchEvent(new MapTestEvent(this.createMapJSON()));
      }
      
      private function onMenuSelect(param1:Event) : void
      {
         if(this.meMap_ != null)
         {
            this.meMap_.clearSelect();
         }
      }
   }
}
