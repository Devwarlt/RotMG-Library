package com.company.assembleegameclient.ui.tooltip
{
   import com.company.assembleegameclient.constants.InventoryOwnerTypes;
   import com.company.assembleegameclient.game.events.KeyInfoResponseSignal;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.ui.LineBreakDesign;
   import com.company.util.BitmapUtil;
   import com.company.util.KeyCodes;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.filters.DropShadowFilter;
   import flash.utils.Dictionary;
   import kabam.rotmg.constants.ActivationType;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.messaging.impl.data.StatData;
   import kabam.rotmg.messaging.impl.incoming.KeyInfoResponse;
   import kabam.rotmg.text.model.TextKey;
   import kabam.rotmg.text.view.TextFieldDisplayConcrete;
   import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
   import kabam.rotmg.text.view.stringBuilder.StringBuilder;
   import kabam.rotmg.ui.model.HUDModel;
   
   public class EquipmentToolTip extends ToolTip
   {
      
      private static const MAX_WIDTH:int = 230;
      
      public static var keyInfo:Dictionary = new Dictionary();
       
      
      private var icon:Bitmap;
      
      public var titleText:TextFieldDisplayConcrete;
      
      private var tierText:TextFieldDisplayConcrete;
      
      private var descText:TextFieldDisplayConcrete;
      
      private var line1:LineBreakDesign;
      
      private var effectsText:TextFieldDisplayConcrete;
      
      private var line2:LineBreakDesign;
      
      private var line3:LineBreakDesign;
      
      private var restrictionsText:TextFieldDisplayConcrete;
      
      private var setInfoText:TextFieldDisplayConcrete;
      
      private var player:Player;
      
      private var isEquippable:Boolean = false;
      
      private var objectType:int;
      
      private var titleOverride:String;
      
      private var descriptionOverride:String;
      
      private var curItemXML:XML = null;
      
      private var objectXML:XML = null;
      
      private var slotTypeToTextBuilder:SlotComparisonFactory;
      
      private var restrictions:Vector.<Restriction>;
      
      private var setInfo:Vector.<Effect>;
      
      private var effects:Vector.<Effect>;
      
      private var uniqueEffects:Vector.<Effect>;
      
      private var itemSlotTypeId:int;
      
      private var invType:int;
      
      private var inventorySlotID:uint;
      
      private var inventoryOwnerType:String;
      
      private var isInventoryFull:Boolean;
      
      private var playerCanUse:Boolean;
      
      private var comparisonResults:SlotComparisonResult;
      
      private var powerText:TextFieldDisplayConcrete;
      
      private var keyInfoResponse:KeyInfoResponseSignal;
      
      private var originalObjectType:int;
      
      public function EquipmentToolTip(param1:int, param2:Player, param3:int, param4:String)
      {
         var _loc8_:HUDModel = null;
         this.uniqueEffects = new Vector.<Effect>();
         this.objectType = param1;
         this.originalObjectType = this.objectType;
         this.player = param2;
         this.invType = param3;
         this.inventoryOwnerType = param4;
         this.isInventoryFull = !!param2?Boolean(param2.isInventoryFull()):false;
         if(this.objectType >= 36864 && this.objectType <= 61440)
         {
            this.objectType = 36863;
         }
         this.playerCanUse = !!param2?Boolean(ObjectLibrary.isUsableByPlayer(this.objectType,param2)):false;
         var _loc5_:int = !!param2?int(ObjectLibrary.getMatchingSlotIndex(this.objectType,param2)):-1;
         var _loc6_:uint = this.playerCanUse || this.player == null?uint(3552822):uint(6036765);
         var _loc7_:uint = this.playerCanUse || param2 == null?uint(10197915):uint(10965039);
         super(_loc6_,1,_loc7_,1,true);
         this.slotTypeToTextBuilder = new SlotComparisonFactory();
         this.objectXML = ObjectLibrary.xmlLibrary_[this.objectType];
         this.isEquippable = _loc5_ != -1;
         this.setInfo = new Vector.<Effect>();
         this.effects = new Vector.<Effect>();
         this.itemSlotTypeId = int(this.objectXML.SlotType);
         if(this.player == null)
         {
            this.curItemXML = this.objectXML;
         }
         else if(this.isEquippable)
         {
            if(this.player.equipment_[_loc5_] != -1)
            {
               this.curItemXML = ObjectLibrary.xmlLibrary_[this.player.equipment_[_loc5_]];
            }
         }
         this.addIcon();
         if(this.originalObjectType >= 36864 && this.originalObjectType <= 61440)
         {
            if(keyInfo[this.originalObjectType] == null)
            {
               this.addTitle();
               this.addDescriptionText();
               this.keyInfoResponse = StaticInjectorContext.getInjector().getInstance(KeyInfoResponseSignal);
               this.keyInfoResponse.add(this.onKeyInfoResponse);
               _loc8_ = StaticInjectorContext.getInjector().getInstance(HUDModel);
               _loc8_.gameSprite.gsc_.keyInfoRequest(this.originalObjectType);
            }
            else
            {
               this.titleOverride = keyInfo[this.originalObjectType][0] + " Key";
               this.descriptionOverride = keyInfo[this.originalObjectType][1] + "\n" + "Created By: " + keyInfo[this.originalObjectType][2];
               this.addTitle();
               this.addDescriptionText();
            }
         }
         else
         {
            this.addTitle();
            this.addDescriptionText();
         }
         this.addTierText();
         this.handleWisMod();
         this.buildCategorySpecificText();
         this.addUniqueEffectsToList();
         this.addNumProjectilesTagsToEffectsList();
         this.addProjectileTagsToEffectsList();
         this.addActivateTagsToEffectsList();
         this.addActivateOnEquipTagsToEffectsList();
         this.addDoseTagsToEffectsList();
         this.addMpCostTagToEffectsList();
         this.addFameBonusTagToEffectsList();
         this.addCooldownTagToEffectsList();
         this.addSetInfo();
         this.makeSetInfoText();
         this.makeEffectsList();
         this.makeLineTwo();
         this.makeRestrictionList();
         this.makeRestrictionText();
         this.makeItemPowerText();
      }
      
      private function addSetInfo() : void
      {
         if(!this.objectXML.hasOwnProperty("@setType"))
         {
            return;
         }
         var _loc1_:int = this.objectXML.attribute("setType");
         this.setInfo.push(new Effect("Part of {name}",{"name":"<b>" + this.objectXML.attribute("setName") + "</b>"}).setColor(TooltipHelper.SET_COLOR).setReplacementsColor(TooltipHelper.SET_COLOR));
         this.addSetActivateOnEquipTagsToEffectsList(_loc1_);
      }
      
      private function addSetActivateOnEquipTagsToEffectsList(param1:int) : void
      {
         var _loc4_:XML = null;
         var _loc2_:uint = 8805920;
         var _loc3_:XML = ObjectLibrary.getSetXMLFromType(param1);
         if(!_loc3_.hasOwnProperty("ActivateOnEquipAll"))
         {
            return;
         }
         for each(_loc4_ in _loc3_.ActivateOnEquipAll)
         {
            if(_loc4_.toString() == "ChangeSkin")
            {
               if(this.player.skinId == int(_loc4_.@skinType))
               {
                  _loc2_ = TooltipHelper.SET_COLOR;
               }
            }
            if(_loc4_.toString() == "IncrementStat")
            {
               this.setInfo.push(new Effect(TextKey.INCREMENT_STAT,this.getComparedStatText(_loc4_)).setColor(_loc2_).setReplacementsColor(_loc2_));
            }
         }
      }
      
      private function makeItemPowerText() : void
      {
         var _loc1_:int = 0;
         if(this.objectXML.hasOwnProperty("feedPower"))
         {
            _loc1_ = this.playerCanUse || this.player == null?16777215:16549442;
            this.powerText = new TextFieldDisplayConcrete().setSize(12).setColor(_loc1_).setBold(true).setTextWidth(MAX_WIDTH - this.icon.width - 4 - 30).setWordWrap(true);
            this.powerText.setStringBuilder(new StaticStringBuilder().setString("Feed Power: " + this.objectXML.feedPower));
            this.powerText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            waiter.push(this.powerText.textChanged);
            addChild(this.powerText);
         }
      }
      
      private function onKeyInfoResponse(param1:KeyInfoResponse) : void
      {
         this.keyInfoResponse.remove(this.onKeyInfoResponse);
         this.removeTitle();
         this.removeDesc();
         this.titleOverride = param1.name;
         this.descriptionOverride = param1.description;
         keyInfo[this.originalObjectType] = [param1.name,param1.description,param1.creator];
         this.addTitle();
         this.addDescriptionText();
      }
      
      private function addUniqueEffectsToList() : void
      {
         var _loc1_:XMLList = null;
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:AppendingLineBuilder = null;
         if(this.objectXML.hasOwnProperty("ExtraTooltipData"))
         {
            _loc1_ = this.objectXML.ExtraTooltipData.EffectInfo;
            for each(_loc2_ in _loc1_)
            {
               _loc3_ = _loc2_.attribute("name");
               _loc4_ = _loc2_.attribute("description");
               _loc5_ = _loc3_ && _loc4_?": ":"\n";
               _loc6_ = new AppendingLineBuilder();
               if(_loc3_)
               {
                  _loc6_.pushParams(_loc3_);
               }
               if(_loc4_)
               {
                  _loc6_.pushParams(_loc4_,{},TooltipHelper.getOpenTag(16777103),TooltipHelper.getCloseTag());
               }
               _loc6_.setDelimiter(_loc5_);
               this.uniqueEffects.push(new Effect(TextKey.BLANK,{"data":_loc6_}));
            }
         }
      }
      
      private function isEmptyEquipSlot() : Boolean
      {
         return this.isEquippable && this.curItemXML == null;
      }
      
      private function addIcon() : void
      {
         var _loc1_:XML = ObjectLibrary.xmlLibrary_[this.objectType];
         var _loc2_:int = 5;
         if(this.objectType == 4874 || this.objectType == 4618)
         {
            _loc2_ = 8;
         }
         if(_loc1_.hasOwnProperty("ScaleValue"))
         {
            _loc2_ = _loc1_.ScaleValue;
         }
         var _loc3_:BitmapData = ObjectLibrary.getRedrawnTextureFromType(this.objectType,60,true,true,_loc2_);
         _loc3_ = BitmapUtil.cropToBitmapData(_loc3_,4,4,_loc3_.width - 8,_loc3_.height - 8);
         this.icon = new Bitmap(_loc3_);
         addChild(this.icon);
      }
      
      private function addTierText() : void
      {
         var _loc1_:* = this.isPet() == false;
         var _loc2_:* = this.objectXML.hasOwnProperty("Consumable") == false;
         var _loc3_:* = this.objectXML.hasOwnProperty("Treasure") == false;
         var _loc4_:Boolean = this.objectXML.hasOwnProperty("Tier");
         if(_loc1_ && _loc2_ && _loc3_)
         {
            this.tierText = new TextFieldDisplayConcrete().setSize(16).setColor(16777215).setTextWidth(30).setBold(true);
            if(_loc4_)
            {
               this.tierText.setStringBuilder(new LineBuilder().setParams(TextKey.TIER_ABBR,{"tier":this.objectXML.Tier}));
            }
            else if(this.objectXML.hasOwnProperty("@setType"))
            {
               this.tierText.setColor(TooltipHelper.SET_COLOR);
               this.tierText.setStringBuilder(new StaticStringBuilder("ST"));
            }
            else
            {
               this.tierText.setColor(TooltipHelper.UNTIERED_COLOR);
               this.tierText.setStringBuilder(new LineBuilder().setParams(TextKey.UNTIERED_ABBR));
            }
            addChild(this.tierText);
         }
      }
      
      private function isPet() : Boolean
      {
         var activateTags:XMLList = null;
         activateTags = this.objectXML.Activate.(text() == "PermaPet");
         return activateTags.length() >= 1;
      }
      
      private function removeTitle() : *
      {
         removeChild(this.titleText);
      }
      
      private function removeDesc() : *
      {
         removeChild(this.descText);
      }
      
      private function addTitle() : void
      {
         var _loc1_:int = this.playerCanUse || this.player == null?16777215:16549442;
         this.titleText = new TextFieldDisplayConcrete().setSize(16).setColor(_loc1_).setBold(true).setTextWidth(MAX_WIDTH - this.icon.width - 4 - 30).setWordWrap(true);
         if(this.titleOverride)
         {
            this.titleText.setStringBuilder(new StaticStringBuilder(this.titleOverride));
         }
         else
         {
            this.titleText.setStringBuilder(new LineBuilder().setParams(ObjectLibrary.typeToDisplayId_[this.objectType]));
         }
         this.titleText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
         waiter.push(this.titleText.textChanged);
         addChild(this.titleText);
      }
      
      private function buildUniqueTooltipData() : String
      {
         var _loc1_:XMLList = null;
         var _loc2_:Vector.<Effect> = null;
         var _loc3_:XML = null;
         if(this.objectXML.hasOwnProperty("ExtraTooltipData"))
         {
            _loc1_ = this.objectXML.ExtraTooltipData.EffectInfo;
            _loc2_ = new Vector.<Effect>();
            for each(_loc3_ in _loc1_)
            {
               _loc2_.push(new Effect(_loc3_.attribute("name"),_loc3_.attribute("description")));
            }
         }
         return "";
      }
      
      private function makeEffectsList() : void
      {
         var _loc1_:AppendingLineBuilder = null;
         if(this.effects.length != 0 || this.comparisonResults.lineBuilder != null || this.objectXML.hasOwnProperty("ExtraTooltipData"))
         {
            this.line1 = new LineBreakDesign(MAX_WIDTH - 12,0);
            this.effectsText = new TextFieldDisplayConcrete().setSize(14).setColor(11776947).setTextWidth(MAX_WIDTH).setWordWrap(true).setHTML(true);
            _loc1_ = this.getEffectsStringBuilder();
            this.effectsText.setStringBuilder(_loc1_);
            this.effectsText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            if(_loc1_.hasLines())
            {
               addChild(this.line1);
               addChild(this.effectsText);
            }
         }
      }
      
      private function getEffectsStringBuilder() : AppendingLineBuilder
      {
         var _loc1_:AppendingLineBuilder = new AppendingLineBuilder();
         this.appendEffects(this.uniqueEffects,_loc1_);
         if(this.comparisonResults.lineBuilder.hasLines())
         {
            _loc1_.pushParams(TextKey.BLANK,{"data":this.comparisonResults.lineBuilder});
         }
         this.appendEffects(this.effects,_loc1_);
         return _loc1_;
      }
      
      private function appendEffects(param1:Vector.<Effect>, param2:AppendingLineBuilder) : void
      {
         var _loc3_:Effect = null;
         var _loc4_:* = null;
         var _loc5_:String = null;
         for each(_loc3_ in param1)
         {
            _loc4_ = "";
            _loc5_ = "";
            if(_loc3_.color_)
            {
               _loc4_ = "<font color=\"#" + _loc3_.color_.toString(16) + "\">";
               _loc5_ = "</font>";
            }
            param2.pushParams(_loc3_.name_,_loc3_.getValueReplacementsWithColor(),_loc4_,_loc5_);
         }
      }
      
      private function addNumProjectilesTagsToEffectsList() : void
      {
         if(this.objectXML.hasOwnProperty("NumProjectiles") && this.comparisonResults.processedTags.hasOwnProperty(this.objectXML.NumProjectiles.toXMLString()) != true)
         {
            this.effects.push(new Effect(TextKey.SHOTS,{"numShots":this.objectXML.NumProjectiles}));
         }
      }
      
      private function addFameBonusTagToEffectsList() : void
      {
         var _loc1_:int = 0;
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         if(this.objectXML.hasOwnProperty("FameBonus"))
         {
            _loc1_ = int(this.objectXML.FameBonus);
            _loc2_ = !!this.playerCanUse?uint(TooltipHelper.BETTER_COLOR):uint(TooltipHelper.NO_DIFF_COLOR);
            if(this.curItemXML != null && this.curItemXML.hasOwnProperty("FameBonus"))
            {
               _loc3_ = int(this.curItemXML.FameBonus.text());
               _loc2_ = TooltipHelper.getTextColor(_loc1_ - _loc3_);
            }
            this.effects.push(new Effect(TextKey.FAME_BONUS,{"percent":this.objectXML.FameBonus + "%"}).setReplacementsColor(_loc2_));
         }
      }
      
      private function addMpCostTagToEffectsList() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.objectXML.hasOwnProperty("MpEndCost"))
         {
            _loc1_ = _loc2_ = this.objectXML.MpEndCost;
            if(this.curItemXML && this.curItemXML.hasOwnProperty("MpEndCost"))
            {
               _loc2_ = this.curItemXML.MpEndCost;
            }
            this.effects.push(new Effect(TextKey.MP_COST,{"cost":TooltipHelper.compare(_loc1_,_loc2_,false)}));
         }
         else if(this.objectXML.hasOwnProperty("MpCost"))
         {
            _loc1_ = _loc2_ = this.objectXML.MpCost;
            if(this.curItemXML && this.curItemXML.hasOwnProperty("MpCost"))
            {
               _loc2_ = this.curItemXML.MpCost;
            }
            this.effects.push(new Effect(TextKey.MP_COST,{"cost":TooltipHelper.compare(_loc1_,_loc2_,false)}));
         }
      }
      
      private function addCooldownTagToEffectsList() : void
      {
         if(this.objectXML.hasOwnProperty("Cooldown"))
         {
            this.effects.push(new Effect("Cooldown: {cd}",{"cd":TooltipHelper.getPlural(this.objectXML.Cooldown,"second")}));
         }
      }
      
      private function addDoseTagsToEffectsList() : void
      {
         if(this.objectXML.hasOwnProperty("Doses"))
         {
            this.effects.push(new Effect(TextKey.DOSES,{"dose":this.objectXML.Doses}));
         }
         if(this.objectXML.hasOwnProperty("Quantity"))
         {
            this.effects.push(new Effect("Quantity: {quantity}",{"quantity":this.objectXML.Quantity}));
         }
      }
      
      private function addProjectileTagsToEffectsList() : void
      {
         var _loc1_:XML = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:XML = null;
         if(this.objectXML.hasOwnProperty("Projectile") && !this.comparisonResults.processedTags.hasOwnProperty(this.objectXML.Projectile.toXMLString()))
         {
            _loc1_ = XML(this.objectXML.Projectile);
            _loc2_ = int(_loc1_.MinDamage);
            _loc3_ = int(_loc1_.MaxDamage);
            this.effects.push(new Effect(TextKey.DAMAGE,{"damage":(_loc2_ == _loc3_?_loc2_:_loc2_ + " - " + _loc3_).toString()}));
            _loc4_ = Number(_loc1_.Speed) * Number(_loc1_.LifetimeMS) / 10000;
            this.effects.push(new Effect(TextKey.RANGE,{"range":TooltipHelper.getFormattedRangeString(_loc4_)}));
            if(this.objectXML.Projectile.hasOwnProperty("MultiHit"))
            {
               this.effects.push(new Effect(TextKey.MULTIHIT,{}).setColor(TooltipHelper.NO_DIFF_COLOR));
            }
            if(this.objectXML.Projectile.hasOwnProperty("PassesCover"))
            {
               this.effects.push(new Effect(TextKey.PASSES_COVER,{}).setColor(TooltipHelper.NO_DIFF_COLOR));
            }
            if(this.objectXML.Projectile.hasOwnProperty("ArmorPiercing"))
            {
               this.effects.push(new Effect(TextKey.ARMOR_PIERCING,{}).setColor(TooltipHelper.NO_DIFF_COLOR));
            }
            for each(_loc5_ in _loc1_.ConditionEffect)
            {
               if(this.comparisonResults.processedTags[_loc5_.toXMLString()] == null)
               {
                  this.effects.push(new Effect(TextKey.SHOT_EFFECT,{"effect":""}));
                  this.effects.push(new Effect(TextKey.EFFECT_FOR_DURATION,{
                     "effect":this.objectXML.Projectile.ConditionEffect,
                     "duration":this.objectXML.Projectile.ConditionEffect.@duration
                  }).setColor(TooltipHelper.NO_DIFF_COLOR));
               }
            }
         }
      }
      
      private function addActivateTagsToEffectsList() : void
      {
         var activateXML:XML = null;
         var val:String = null;
         var stat:int = 0;
         var amt:int = 0;
         var test:String = null;
         var activationType:String = null;
         var compareXML:XML = null;
         var effectColor:uint = 0;
         var current:XML = null;
         var tokens:Object = null;
         var template:String = null;
         var effectColor2:uint = 0;
         var current2:XML = null;
         var statStr:String = null;
         var tokens2:Object = null;
         var template2:String = null;
         var replaceParams:Object = null;
         var rNew:Number = NaN;
         var rCurrent:Number = NaN;
         var dNew:Number = NaN;
         var dCurrent:Number = NaN;
         var comparer:Number = NaN;
         var rNew2:Number = NaN;
         var rCurrent2:Number = NaN;
         var dNew2:Number = NaN;
         var dCurrent2:Number = NaN;
         var aNew2:Number = NaN;
         var aCurrent2:Number = NaN;
         var comparer2:Number = NaN;
         var alb:AppendingLineBuilder = null;
         for each(activateXML in this.objectXML.Activate)
         {
            test = this.comparisonResults.processedTags[activateXML.toXMLString()];
            if(this.comparisonResults.processedTags[activateXML.toXMLString()] == true)
            {
               continue;
            }
            activationType = activateXML.toString();
            compareXML = this.curItemXML == null?null:this.curItemXML.Activate.(text() == activationType)[0];
            switch(activationType)
            {
               case ActivationType.COND_EFFECT_AURA:
                  this.effects.push(new Effect(TextKey.PARTY_EFFECT,{"effect":new AppendingLineBuilder().pushParams(TextKey.WITHIN_SQRS,{"range":activateXML.@range},TooltipHelper.getOpenTag(TooltipHelper.NO_DIFF_COLOR),TooltipHelper.getCloseTag())}));
                  this.effects.push(new Effect(TextKey.EFFECT_FOR_DURATION,{
                     "effect":activateXML.@effect,
                     "duration":activateXML.@duration
                  }).setColor(TooltipHelper.NO_DIFF_COLOR));
                  continue;
               case ActivationType.COND_EFFECT_SELF:
                  this.effects.push(new Effect(TextKey.EFFECT_ON_SELF,{"effect":""}));
                  this.effects.push(new Effect(TextKey.EFFECT_FOR_DURATION,{
                     "effect":activateXML.@effect,
                     "duration":activateXML.@duration
                  }));
                  continue;
               case ActivationType.HEAL:
                  this.effects.push(new Effect(TextKey.INCREMENT_STAT,{
                     "statAmount":"+" + activateXML.@amount + " ",
                     "statName":new LineBuilder().setParams(TextKey.STATUS_BAR_HEALTH_POINTS)
                  }));
                  continue;
               case ActivationType.HEAL_NOVA:
                  this.effects.push(new Effect(TextKey.PARTY_HEAL,{"effect":new AppendingLineBuilder().pushParams(TextKey.HP_WITHIN_SQRS,{
                     "amount":activateXML.@amount,
                     "range":activateXML.@range
                  },TooltipHelper.getOpenTag(TooltipHelper.NO_DIFF_COLOR),TooltipHelper.getCloseTag())}));
                  continue;
               case ActivationType.MAGIC:
                  this.effects.push(new Effect(TextKey.INCREMENT_STAT,{
                     "statAmount":"+" + activateXML.@amount + " ",
                     "statName":new LineBuilder().setParams(TextKey.STATUS_BAR_MANA_POINTS)
                  }));
                  continue;
               case ActivationType.MAGIC_NOVA:
                  this.effects.push(new Effect(TextKey.FILL_PARTY_MAGIC,activateXML.@amount + " MP at " + activateXML.@range + " sqrs"));
                  continue;
               case ActivationType.TELEPORT:
                  this.effects.push(new Effect(TextKey.BLANK,{"data":new LineBuilder().setParams(TextKey.TELEPORT_TO_TARGET)}));
                  continue;
               case ActivationType.VAMPIRE_BLAST:
                  this.effects.push(new Effect(TextKey.STEAL,{"effect":new AppendingLineBuilder().pushParams(TextKey.HP_WITHIN_SQRS,{
                     "amount":activateXML.@totalDamage,
                     "range":activateXML.@radius
                  },TooltipHelper.getOpenTag(TooltipHelper.NO_DIFF_COLOR),TooltipHelper.getCloseTag())}));
                  continue;
               case ActivationType.TRAP:
                  this.getTrap(activateXML,compareXML);
                  continue;
               case ActivationType.STASIS_BLAST:
                  this.effects.push(new Effect(TextKey.STASIS_GROUP,{"stasis":new AppendingLineBuilder().pushParams(TextKey.SEC_COUNT,{"duration":activateXML.@duration},TooltipHelper.getOpenTag(TooltipHelper.NO_DIFF_COLOR),TooltipHelper.getCloseTag())}));
                  continue;
               case ActivationType.DECOY:
                  this.effects.push(new Effect(TextKey.DECOY,{"data":new AppendingLineBuilder().pushParams(TextKey.SEC_COUNT,{"duration":activateXML.@duration},TooltipHelper.getOpenTag(TooltipHelper.NO_DIFF_COLOR),TooltipHelper.getCloseTag())}));
                  continue;
               case ActivationType.LIGHTNING:
                  this.getLightning(activateXML,compareXML);
                  continue;
               case ActivationType.POISON_GRENADE:
                  this.effects.push(new Effect(TextKey.POISON_GRENADE,{"data":""}));
                  this.effects.push(new Effect(TextKey.POISON_GRENADE_DATA,{
                     "damage":activateXML.@totalDamage,
                     "duration":activateXML.@duration,
                     "radius":activateXML.@radius
                  }).setColor(TooltipHelper.NO_DIFF_COLOR));
                  continue;
               case ActivationType.REMOVE_NEG_COND:
                  this.effects.push(new Effect(TextKey.REMOVES_NEGATIVE,{}).setColor(TooltipHelper.NO_DIFF_COLOR));
                  continue;
               case ActivationType.REMOVE_NEG_COND_SELF:
                  this.effects.push(new Effect(TextKey.REMOVES_NEGATIVE,{}).setColor(TooltipHelper.NO_DIFF_COLOR));
                  continue;
               case ActivationType.GENERIC_ACTIVATE:
                  effectColor = 16777103;
                  if(this.curItemXML != null)
                  {
                     current = this.getEffectTag(this.curItemXML,activateXML.@effect);
                     if(current != null)
                     {
                        rNew = Number(activateXML.@range);
                        rCurrent = Number(current.@range);
                        dNew = Number(activateXML.@duration);
                        dCurrent = Number(current.@duration);
                        comparer = rNew - rCurrent + (dNew - dCurrent);
                        if(comparer > 0)
                        {
                           effectColor = 65280;
                        }
                        else if(comparer < 0)
                        {
                           effectColor = 16711680;
                        }
                     }
                  }
                  tokens = {
                     "range":activateXML.@range,
                     "effect":activateXML.@effect,
                     "duration":activateXML.@duration
                  };
                  template = "Within {range} sqrs {effect} for {duration} seconds";
                  if(activateXML.@target != "enemy")
                  {
                     this.effects.push(new Effect(TextKey.PARTY_EFFECT,{"effect":LineBuilder.returnStringReplace(template,tokens)}).setReplacementsColor(effectColor));
                  }
                  else
                  {
                     this.effects.push(new Effect(TextKey.ENEMY_EFFECT,{"effect":LineBuilder.returnStringReplace(template,tokens)}).setReplacementsColor(effectColor));
                  }
                  continue;
               case ActivationType.STAT_BOOST_AURA:
                  effectColor2 = 16777103;
                  if(this.curItemXML != null)
                  {
                     current2 = this.getStatTag(this.curItemXML,activateXML.@stat);
                     if(current2 != null)
                     {
                        rNew2 = Number(activateXML.@range);
                        rCurrent2 = Number(current2.@range);
                        dNew2 = Number(activateXML.@duration);
                        dCurrent2 = Number(current2.@duration);
                        aNew2 = Number(activateXML.@amount);
                        aCurrent2 = Number(current2.@amount);
                        comparer2 = rNew2 - rCurrent2 + (dNew2 - dCurrent2) + (aNew2 - aCurrent2);
                        if(comparer2 > 0)
                        {
                           effectColor2 = 65280;
                        }
                        else if(comparer2 < 0)
                        {
                           effectColor2 = 16711680;
                        }
                     }
                  }
                  stat = int(activateXML.@stat);
                  statStr = LineBuilder.getLocalizedString2(StatData.statToName(stat));
                  tokens2 = {
                     "range":activateXML.@range,
                     "stat":statStr,
                     "amount":activateXML.@amount,
                     "duration":activateXML.@duration
                  };
                  template2 = "Within {range} sqrs increase {stat} by {amount} for {duration} seconds";
                  this.effects.push(new Effect(TextKey.PARTY_EFFECT,{"effect":LineBuilder.returnStringReplace(template2,tokens2)}).setReplacementsColor(effectColor2));
                  continue;
               case ActivationType.INCREMENT_STAT:
                  stat = int(activateXML.@stat);
                  amt = int(activateXML.@amount);
                  replaceParams = {};
                  if(stat != StatData.HP_STAT && stat != StatData.MP_STAT)
                  {
                     val = TextKey.PERMANENTLY_INCREASES;
                     replaceParams["statName"] = new LineBuilder().setParams(StatData.statToName(stat));
                     this.effects.push(new Effect(val,replaceParams).setColor(16777103));
                  }
                  else
                  {
                     val = TextKey.BLANK;
                     alb = new AppendingLineBuilder().setDelimiter(" ");
                     alb.pushParams(TextKey.BLANK,{"data":new StaticStringBuilder("+" + amt)});
                     alb.pushParams(StatData.statToName(stat));
                     replaceParams["data"] = alb;
                     this.effects.push(new Effect(val,replaceParams));
                  }
                  continue;
               default:
                  continue;
            }
         }
      }
      
      private function getSkull(param1:XML, param2:XML = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         _loc3_ = _loc4_ = param1.@totalDamage;
         if(param2)
         {
            _loc4_ = param2.@totalDamage;
         }
         _loc5_ = _loc6_ = param1.@radius;
         if(param2)
         {
            _loc6_ = param2.@radius;
         }
         _loc7_ = _loc8_ = param1.@heal;
         if(param2)
         {
            _loc8_ = param2.@heal;
         }
         _loc9_ = _loc10_ = !!param1.hasOwnProperty("@ignoreDef")?int(param1.@ignoreDef):0;
         if(param2)
         {
            _loc10_ = !!param2.hasOwnProperty("@ignoreDef")?int(param2.@ignoreDef):0;
         }
         var _loc11_:* = this.colorUntiered("Skull: ");
         _loc11_ = _loc11_ + "{damage} damage within {radius} squares\n";
         _loc11_ = _loc11_ + "Steals {heal} HP";
         if(_loc9_)
         {
            _loc11_ = _loc11_ + " and ignores {ignoreDef} defense";
         }
         this.effects.push(new Effect(_loc11_,{
            "damage":TooltipHelper.compare(_loc3_,_loc4_),
            "radius":TooltipHelper.compare(_loc5_,_loc6_),
            "heal":TooltipHelper.compare(_loc7_,_loc8_),
            "ignoreDef":TooltipHelper.compare(_loc9_,_loc10_)
         }));
      }
      
      private function getTrap(param1:XML, param2:XML = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:String = null;
         _loc3_ = _loc4_ = param1.@totalDamage;
         if(param2)
         {
            _loc4_ = param2.@totalDamage;
         }
         _loc5_ = _loc6_ = param1.@radius;
         if(param2)
         {
            _loc6_ = param2.@radius;
         }
         _loc7_ = _loc8_ = !!param1.hasOwnProperty("@duration")?Number(param1.@duration):Number(20);
         if(param2)
         {
            _loc8_ = !!param2.hasOwnProperty("@duration")?Number(param2.@duration):Number(20);
         }
         _loc9_ = _loc10_ = !!param1.hasOwnProperty("@tilArmed")?Number(param1.@tilArmed):Number(1);
         if(param2)
         {
            _loc10_ = !!param2.hasOwnProperty("@tilArmed")?Number(param2.@tilArmed):Number(1);
         }
         var _loc11_:* = this.colorUntiered("Trap: ");
         _loc11_ = _loc11_ + "{damage} damage within {radius} squares";
         this.effects.push(new Effect(_loc11_,{
            "damage":TooltipHelper.compare(_loc3_,_loc4_),
            "radius":TooltipHelper.compare(_loc5_,_loc6_)
         }));
         var _loc12_:String = !!param1.hasOwnProperty("@condEffect")?param1.@condEffect:"Slowed";
         if(_loc12_ != "Nothing")
         {
            _loc13_ = _loc14_ = !!param1.hasOwnProperty("@condDuration")?int(param1.@condDuration):5;
            if(param2)
            {
               _loc14_ = !!param2.hasOwnProperty("@condDuration")?int(param2.@condDuration):5;
               _loc15_ = !!param2.hasOwnProperty("@condEffect")?param2.@condEffect:"Slowed";
               if(_loc15_ == "Nothing")
               {
                  _loc14_ = 0;
               }
            }
            this.effects.push(new Effect("{condition} for {duration} ",{
               "condition":_loc12_,
               "duration":TooltipHelper.compareAndGetPlural(_loc13_,_loc14_,"second")
            }));
         }
         this.effects.push(new Effect("{tilArmed} to arm for {duration} ",{
            "tilArmed":TooltipHelper.compareAndGetPlural(_loc9_,_loc10_,"second",false),
            "duration":TooltipHelper.compareAndGetPlural(_loc7_,_loc8_,"second")
         }));
      }
      
      private function getLightning(param1:XML, param2:XML = null) : void
      {
         var _loc13_:Number = NaN;
         var _loc3_:int = this.player.wisdom_;
         var _loc4_:ComPair = new ComPair(param1,param2,"decrDamage",0);
         var _loc5_:int = this.GetIntArgument(param1,"wisPerTarget",10);
         var _loc6_:int = this.GetIntArgument(param1,"wisDamageBase",_loc4_.a);
         var _loc7_:int = this.GetIntArgument(param1,"wisMin",50);
         var _loc8_:Number = 0;
         if(_loc3_ > _loc7_)
         {
            _loc8_ = (_loc3_ - _loc7_) / _loc5_;
         }
         var _loc9_:ComPair = new ComPair(param1,param2,"maxTargets");
         _loc9_.add(_loc8_);
         var _loc10_:ComPair = new ComPair(param1,param2,"totalDamage");
         _loc10_.add(_loc6_ * _loc8_);
         var _loc11_:* = this.colorUntiered("Lightning: ");
         _loc11_ = _loc11_ + ("{targets}" + this.colorWisBonus(int(_loc8_)) + " targets\n");
         _loc11_ = _loc11_ + ("{damage}" + this.colorWisBonus(int(_loc6_ * _loc8_)) + " damage");
         if(_loc4_)
         {
            _loc11_ = _loc11_ + ", reduced by \n{decrDamage} for each subsequent target";
         }
         this.effects.push(new Effect(_loc11_,{
            "targets":TooltipHelper.compare(_loc9_.a,_loc9_.b),
            "damage":TooltipHelper.compare(_loc10_.a,_loc10_.b),
            "decrDamage":TooltipHelper.compare(_loc4_.a,_loc4_.b,false)
         }));
         var _loc12_:String = param1.@condEffect;
         if(_loc12_)
         {
            _loc13_ = this.GetFloatArgument(param1,"condDuration",5);
            this.effects.push(new Effect("{condition} for {duration} ",{
               "condition":_loc12_,
               "duration":TooltipHelper.getPlural(_loc13_,"second")
            }));
         }
      }
      
      private function GetIntArgument(param1:XML, param2:String, param3:int = 0) : int
      {
         return !!param1.hasOwnProperty("@" + param2)?int(param1[param2]):int(param3);
      }
      
      private function GetFloatArgument(param1:XML, param2:String, param3:Number = 0) : Number
      {
         return !!param1.hasOwnProperty("@" + param2)?Number(param1[param2]):Number(param3);
      }
      
      private function GetStringArgument(param1:XML, param2:String, param3:String = "") : String
      {
         return !!param1.hasOwnProperty("@" + param2)?param1[param2]:param3;
      }
      
      private function colorWisBonus(param1:Number) : String
      {
         if(param1)
         {
            return TooltipHelper.wrapInFontTag(" (+" + param1 + ")","#" + TooltipHelper.WIS_BONUS_COLOR.toString(16));
         }
         return "";
      }
      
      private function colorUntiered(param1:String) : String
      {
         var _loc2_:Boolean = this.objectXML.hasOwnProperty("Tier");
         var _loc3_:Boolean = this.objectXML.hasOwnProperty("@setType");
         if(_loc3_)
         {
            return TooltipHelper.wrapInFontTag(param1,"#" + TooltipHelper.SET_COLOR.toString(16));
         }
         if(!_loc2_)
         {
            return TooltipHelper.wrapInFontTag(param1,"#" + TooltipHelper.UNTIERED_COLOR.toString(16));
         }
         return param1;
      }
      
      private function getEffectTag(param1:XML, param2:String) : XML
      {
         var matches:XMLList = null;
         var tag:XML = null;
         var xml:XML = param1;
         var effectValue:String = param2;
         matches = xml.Activate.(text() == ActivationType.GENERIC_ACTIVATE);
         for each(tag in matches)
         {
            if(tag.@effect == effectValue)
            {
               return tag;
            }
         }
         return null;
      }
      
      private function getStatTag(param1:XML, param2:String) : XML
      {
         var matches:XMLList = null;
         var tag:XML = null;
         var xml:XML = param1;
         var statValue:String = param2;
         matches = xml.Activate.(text() == ActivationType.STAT_BOOST_AURA);
         for each(tag in matches)
         {
            if(tag.@stat == statValue)
            {
               return tag;
            }
         }
         return null;
      }
      
      private function addActivateOnEquipTagsToEffectsList() : void
      {
         var _loc1_:XML = null;
         var _loc2_:Boolean = true;
         for each(_loc1_ in this.objectXML.ActivateOnEquip)
         {
            if(_loc2_)
            {
               this.effects.push(new Effect(TextKey.ON_EQUIP,""));
               _loc2_ = false;
            }
            if(_loc1_.toString() == "IncrementStat")
            {
               this.effects.push(new Effect(TextKey.INCREMENT_STAT,this.getComparedStatText(_loc1_)).setReplacementsColor(this.getComparedStatColor(_loc1_)));
            }
         }
      }
      
      private function getComparedStatText(param1:XML) : Object
      {
         var _loc2_:int = int(param1.@stat);
         var _loc3_:int = int(param1.@amount);
         var _loc4_:String = _loc3_ > -1?"+":"";
         return {
            "statAmount":_loc4_ + String(_loc3_) + " ",
            "statName":new LineBuilder().setParams(StatData.statToName(_loc2_))
         };
      }
      
      private function getComparedStatColor(param1:XML) : uint
      {
         var match:XML = null;
         var otherAmount:int = 0;
         var activateXML:XML = param1;
         var stat:int = int(activateXML.@stat);
         var amount:int = int(activateXML.@amount);
         var textColor:uint = !!this.playerCanUse?uint(TooltipHelper.BETTER_COLOR):uint(TooltipHelper.NO_DIFF_COLOR);
         var otherMatches:XMLList = null;
         if(this.curItemXML != null)
         {
            otherMatches = this.curItemXML.ActivateOnEquip.(@stat == stat);
         }
         if(otherMatches != null && otherMatches.length() == 1)
         {
            match = XML(otherMatches[0]);
            otherAmount = int(match.@amount);
            textColor = TooltipHelper.getTextColor(amount - otherAmount);
         }
         if(amount < 0)
         {
            textColor = 16711680;
         }
         return textColor;
      }
      
      private function addEquipmentItemRestrictions() : void
      {
         if(this.objectXML.hasOwnProperty("Treasure") == false)
         {
            this.restrictions.push(new Restriction(TextKey.EQUIP_TO_USE,11776947,false));
            if(this.isInventoryFull || this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)
            {
               this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_EQUIP,11776947,false));
            }
            else
            {
               this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_TAKE,11776947,false));
            }
         }
      }
      
      private function addAbilityItemRestrictions() : void
      {
         this.restrictions.push(new Restriction(TextKey.KEYCODE_TO_USE,16777215,false));
      }
      
      private function addConsumableItemRestrictions() : void
      {
         this.restrictions.push(new Restriction(TextKey.CONSUMED_WITH_USE,11776947,false));
         if(this.isInventoryFull || this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)
         {
            this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_OR_SHIFT_CLICK_TO_USE,16777215,false));
         }
         else
         {
            this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_TAKE_SHIFT_CLICK_USE,16777215,false));
         }
      }
      
      private function addReusableItemRestrictions() : void
      {
         this.restrictions.push(new Restriction(TextKey.CAN_BE_USED_MULTIPLE_TIMES,11776947,false));
         this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_OR_SHIFT_CLICK_TO_USE,16777215,false));
      }
      
      private function makeRestrictionList() : void
      {
         var _loc2_:XML = null;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.restrictions = new Vector.<Restriction>();
         if(this.objectXML.hasOwnProperty("VaultItem") && this.invType != -1 && this.invType != ObjectLibrary.idToType_["Vault Chest"])
         {
            this.restrictions.push(new Restriction(TextKey.STORE_IN_VAULT,16549442,true));
         }
         if(this.objectXML.hasOwnProperty("Soulbound"))
         {
            this.restrictions.push(new Restriction(TextKey.ITEM_SOULBOUND,11776947,false));
         }
         if(this.playerCanUse)
         {
            if(this.objectXML.hasOwnProperty("Usable"))
            {
               this.addAbilityItemRestrictions();
               this.addEquipmentItemRestrictions();
            }
            else if(this.objectXML.hasOwnProperty("Consumable"))
            {
               this.addConsumableItemRestrictions();
            }
            else if(this.objectXML.hasOwnProperty("InvUse"))
            {
               this.addReusableItemRestrictions();
            }
            else
            {
               this.addEquipmentItemRestrictions();
            }
         }
         else if(this.player != null)
         {
            this.restrictions.push(new Restriction(TextKey.NOT_USABLE_BY,16549442,true));
         }
         var _loc1_:Vector.<String> = ObjectLibrary.usableBy(this.objectType);
         if(_loc1_ != null)
         {
            this.restrictions.push(new Restriction(TextKey.USABLE_BY,11776947,false));
         }
         for each(_loc2_ in this.objectXML.EquipRequirement)
         {
            _loc3_ = ObjectLibrary.playerMeetsRequirement(_loc2_,this.player);
            if(_loc2_.toString() == "Stat")
            {
               _loc4_ = int(_loc2_.@stat);
               _loc5_ = int(_loc2_.@value);
               this.restrictions.push(new Restriction("Requires " + StatData.statToName(_loc4_) + " of " + _loc5_,!!_loc3_?uint(11776947):uint(16549442),!!_loc3_?false:true));
            }
         }
      }
      
      private function makeLineTwo() : void
      {
         this.line2 = new LineBreakDesign(MAX_WIDTH - 12,0);
         addChild(this.line2);
      }
      
      private function makeLineThree() : void
      {
         this.line3 = new LineBreakDesign(MAX_WIDTH - 12,0);
         addChild(this.line3);
      }
      
      private function makeRestrictionText() : void
      {
         if(this.restrictions.length != 0)
         {
            this.restrictionsText = new TextFieldDisplayConcrete().setSize(14).setColor(11776947).setTextWidth(MAX_WIDTH - 4).setIndent(-10).setLeftMargin(10).setWordWrap(true).setHTML(true);
            this.restrictionsText.setStringBuilder(this.buildRestrictionsLineBuilder());
            this.restrictionsText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            waiter.push(this.restrictionsText.textChanged);
            addChild(this.restrictionsText);
         }
      }
      
      private function makeSetInfoText() : void
      {
         if(this.setInfo.length != 0)
         {
            this.setInfoText = new TextFieldDisplayConcrete().setSize(14).setColor(11776947).setTextWidth(MAX_WIDTH - 4).setIndent(-10).setLeftMargin(10).setWordWrap(true).setHTML(true);
            this.setInfoText.setStringBuilder(this.getSetBonusStringBuilder());
            this.setInfoText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            waiter.push(this.setInfoText.textChanged);
            addChild(this.setInfoText);
            this.makeLineThree();
         }
      }
      
      private function getSetBonusStringBuilder() : AppendingLineBuilder
      {
         var _loc1_:AppendingLineBuilder = new AppendingLineBuilder();
         this.appendEffects(this.setInfo,_loc1_);
         return _loc1_;
      }
      
      private function buildRestrictionsLineBuilder() : StringBuilder
      {
         var _loc2_:Restriction = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc1_:AppendingLineBuilder = new AppendingLineBuilder();
         for each(_loc2_ in this.restrictions)
         {
            _loc3_ = !!_loc2_.bold_?"<b>":"";
            _loc3_ = _loc3_.concat("<font color=\"#" + _loc2_.color_.toString(16) + "\">");
            _loc4_ = "</font>";
            _loc4_ = _loc4_.concat(!!_loc2_.bold_?"</b>":"");
            _loc5_ = !!this.player?ObjectLibrary.typeToDisplayId_[this.player.objectType_]:"";
            _loc1_.pushParams(_loc2_.text_,{
               "unUsableClass":_loc5_,
               "usableClasses":this.getUsableClasses(),
               "keyCode":KeyCodes.CharCodeStrings[Parameters.data_.useSpecial]
            },_loc3_,_loc4_);
         }
         return _loc1_;
      }
      
      private function getUsableClasses() : StringBuilder
      {
         var _loc3_:String = null;
         var _loc1_:Vector.<String> = ObjectLibrary.usableBy(this.objectType);
         var _loc2_:AppendingLineBuilder = new AppendingLineBuilder();
         _loc2_.setDelimiter(", ");
         for each(_loc3_ in _loc1_)
         {
            _loc2_.pushParams(_loc3_);
         }
         return _loc2_;
      }
      
      private function addDescriptionText() : void
      {
         this.descText = new TextFieldDisplayConcrete().setSize(14).setColor(11776947).setTextWidth(MAX_WIDTH).setWordWrap(true);
         if(this.descriptionOverride)
         {
            this.descText.setStringBuilder(new StaticStringBuilder(this.descriptionOverride));
         }
         else
         {
            this.descText.setStringBuilder(new LineBuilder().setParams(String(this.objectXML.Description)));
         }
         this.descText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
         waiter.push(this.descText.textChanged);
         addChild(this.descText);
      }
      
      override protected function alignUI() : void
      {
         this.titleText.x = this.icon.width + 4;
         this.titleText.y = this.icon.height / 2 - this.titleText.height / 2;
         if(this.tierText)
         {
            this.tierText.y = this.icon.height / 2 - this.tierText.height / 2;
            this.tierText.x = MAX_WIDTH - 30;
         }
         this.descText.x = 4;
         this.descText.y = this.icon.height + 2;
         if(contains(this.line1))
         {
            this.line1.x = 8;
            this.line1.y = this.descText.y + this.descText.height + 8;
            this.effectsText.x = 4;
            this.effectsText.y = this.line1.y + 8;
         }
         else
         {
            this.line1.y = this.descText.y + this.descText.height;
            this.effectsText.y = this.line1.y;
         }
         if(this.setInfoText)
         {
            this.line3.x = 8;
            this.line3.y = this.effectsText.y + this.effectsText.height + 8;
            this.setInfoText.x = 4;
            this.setInfoText.y = this.line3.y + 8;
            this.line2.x = 8;
            this.line2.y = this.setInfoText.y + this.setInfoText.height + 8;
         }
         else
         {
            this.line2.x = 8;
            this.line2.y = this.effectsText.y + this.effectsText.height + 8;
         }
         var _loc1_:uint = this.line2.y + 8;
         if(this.restrictionsText)
         {
            this.restrictionsText.x = 4;
            this.restrictionsText.y = _loc1_;
            _loc1_ = _loc1_ + this.restrictionsText.height;
         }
         if(this.powerText)
         {
            if(contains(this.powerText))
            {
               this.powerText.x = 4;
               this.powerText.y = _loc1_;
            }
         }
      }
      
      private function buildCategorySpecificText() : void
      {
         if(this.curItemXML != null)
         {
            this.comparisonResults = this.slotTypeToTextBuilder.getComparisonResults(this.objectXML,this.curItemXML);
         }
         else
         {
            this.comparisonResults = new SlotComparisonResult();
         }
      }
      
      private function handleWisMod() : void
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(this.player == null)
         {
            return;
         }
         var _loc1_:Number = this.player.wisdom_ + this.player.wisdomBoost_;
         if(_loc1_ < 30)
         {
            return;
         }
         var _loc2_:Vector.<XML> = new Vector.<XML>();
         if(this.curItemXML != null)
         {
            this.curItemXML = this.curItemXML.copy();
            _loc2_.push(this.curItemXML);
         }
         if(this.objectXML != null)
         {
            this.objectXML = this.objectXML.copy();
            _loc2_.push(this.objectXML);
         }
         for each(_loc4_ in _loc2_)
         {
            for each(_loc3_ in _loc4_.Activate)
            {
               _loc5_ = _loc3_.toString();
               if(_loc3_.@effect == "Stasis")
               {
                  continue;
               }
               _loc6_ = _loc3_.@useWisMod;
               if(_loc6_ == "" || _loc6_ == "false" || _loc6_ == "0" || _loc3_.@effect == "Stasis")
               {
                  continue;
               }
               switch(_loc5_)
               {
                  case ActivationType.HEAL_NOVA:
                     _loc3_.@amount = this.modifyWisModStat(_loc3_.@amount,0);
                     _loc3_.@range = this.modifyWisModStat(_loc3_.@range);
                     continue;
                  case ActivationType.COND_EFFECT_AURA:
                     _loc3_.@duration = this.modifyWisModStat(_loc3_.@duration);
                     _loc3_.@range = this.modifyWisModStat(_loc3_.@range);
                     continue;
                  case ActivationType.COND_EFFECT_SELF:
                     _loc3_.@duration = this.modifyWisModStat(_loc3_.@duration);
                     continue;
                  case ActivationType.STAT_BOOST_AURA:
                     _loc3_.@amount = this.modifyWisModStat(_loc3_.@amount,0);
                     _loc3_.@duration = this.modifyWisModStat(_loc3_.@duration);
                     _loc3_.@range = this.modifyWisModStat(_loc3_.@range);
                     continue;
                  case ActivationType.GENERIC_ACTIVATE:
                     _loc3_.@duration = this.modifyWisModStat(_loc3_.@duration);
                     _loc3_.@range = this.modifyWisModStat(_loc3_.@range);
                     continue;
                  default:
                     continue;
               }
            }
         }
      }
      
      private function modifyWisModStat(param1:String, param2:Number = 1) : String
      {
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc3_:String = "-1";
         var _loc4_:Number = this.player.wisdom_ + this.player.wisdomBoost_;
         if(_loc4_ < 30)
         {
            _loc3_ = param1;
         }
         else
         {
            _loc5_ = Number(param1);
            _loc6_ = _loc5_ < 0?-1:1;
            _loc7_ = _loc5_ * _loc4_ / 150 + _loc5_ * _loc6_;
            _loc7_ = Math.floor(_loc7_ * Math.pow(10,param2)) / Math.pow(10,param2);
            if(_loc7_ - int(_loc7_) * _loc6_ >= 1 / Math.pow(10,param2) * _loc6_)
            {
               _loc3_ = _loc7_.toFixed(1);
            }
            else
            {
               _loc3_ = _loc7_.toFixed(0);
            }
         }
         return _loc3_;
      }
   }
}

class ComPair
{
    
   
   public var a:Number;
   
   public var b:Number;
   
   function ComPair(param1:XML, param2:XML, param3:String, param4:Number = 0)
   {
      super();
      this.a = this.b = !!param1.hasOwnProperty("@" + param3)?Number(param1[param3]):Number(param4);
      if(param2)
      {
         this.b = !!param2.hasOwnProperty("@" + param3)?Number(param2[param3]):Number(param4);
      }
   }
   
   public function add(param1:int) : void
   {
      this.a = this.a + param1;
      this.b = this.b + param1;
   }
}

import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

class Effect
{
    
   
   public var name_:String;
   
   public var valueReplacements_:Object;
   
   public var replacementColor_:uint = 16777103;
   
   public var color_:uint = 11776947;
   
   function Effect(param1:String, param2:Object)
   {
      super();
      this.name_ = param1;
      this.valueReplacements_ = param2;
   }
   
   public function setColor(param1:uint) : Effect
   {
      this.color_ = param1;
      return this;
   }
   
   public function setReplacementsColor(param1:uint) : Effect
   {
      this.replacementColor_ = param1;
      return this;
   }
   
   public function getValueReplacementsWithColor() : Object
   {
      var _loc4_:* = null;
      var _loc5_:LineBuilder = null;
      var _loc1_:Object = {};
      var _loc2_:* = "";
      var _loc3_:* = "";
      if(this.replacementColor_)
      {
         _loc2_ = "</font><font color=\"#" + this.replacementColor_.toString(16) + "\">";
         _loc3_ = "</font><font color=\"#" + this.color_.toString(16) + "\">";
      }
      for(_loc4_ in this.valueReplacements_)
      {
         if(this.valueReplacements_[_loc4_] is AppendingLineBuilder)
         {
            _loc1_[_loc4_] = this.valueReplacements_[_loc4_];
         }
         else if(this.valueReplacements_[_loc4_] is LineBuilder)
         {
            _loc5_ = this.valueReplacements_[_loc4_] as LineBuilder;
            _loc5_.setPrefix(_loc2_).setPostfix(_loc3_);
            _loc1_[_loc4_] = _loc5_;
         }
         else
         {
            _loc1_[_loc4_] = _loc2_ + this.valueReplacements_[_loc4_] + _loc3_;
         }
      }
      return _loc1_;
   }
}

class Restriction
{
    
   
   public var text_:String;
   
   public var color_:uint;
   
   public var bold_:Boolean;
   
   function Restriction(param1:String, param2:uint, param3:Boolean)
   {
      super();
      this.text_ = param1;
      this.color_ = param2;
      this.bold_ = param3;
   }
}
