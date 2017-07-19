package kabam.rotmg.mysterybox.components
{
   import com.company.assembleegameclient.ui.dialogs.Dialog;
   import com.company.assembleegameclient.util.Currency;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import flash.utils.getTimer;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.dialogs.control.OpenDialogSignal;
   import kabam.rotmg.mysterybox.model.MysteryBoxInfo;
   import kabam.rotmg.pets.view.components.PopupWindowBackground;
   import kabam.rotmg.text.view.TextFieldDisplayConcrete;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
   import kabam.rotmg.util.components.LegacyBuyButton;
   import kabam.rotmg.util.components.UIAssetsHelper;
   
   public class MysteryBoxSelectEntry extends Sprite
   {
      
      public static var redBarEmbed:Class = MysteryBoxSelectEntry_redBarEmbed;
       
      
      public var mbi:MysteryBoxInfo;
      
      private var buyButton:LegacyBuyButton;
      
      private var leftNavSprite:Sprite;
      
      private var rightNavSprite:Sprite;
      
      private var iconImage:DisplayObject;
      
      private var infoImageBorder:PopupWindowBackground;
      
      private var infoImage:DisplayObject;
      
      private var newText:TextFieldDisplayConcrete;
      
      private var sale:TextFieldDisplayConcrete;
      
      private var left:TextFieldDisplayConcrete;
      
      private var hoverState:Boolean = false;
      
      private var descriptionShowing:Boolean = false;
      
      private var redbar:DisplayObject;
      
      private const newString:String = "MysteryBoxSelectEntry.newString";
      
      private const onSaleString:String = "MysteryBoxSelectEntry.onSaleString";
      
      private const saleEndString:String = "MysteryBoxSelectEntry.saleEndString";
      
      private var soldOut:Boolean;
      
      private var quantity_:int;
      
      private var title:TextFieldDisplayConcrete;
      
      public function MysteryBoxSelectEntry(param1:MysteryBoxInfo)
      {
         var _loc2_:DisplayObject = null;
         super();
         this.redbar = new redBarEmbed();
         this.redbar.y = -5;
         this.redbar.width = MysteryBoxSelectModal.modalWidth - 5;
         this.redbar.height = MysteryBoxSelectModal.aMysteryBoxHeight - 8;
         addChild(this.redbar);
         _loc2_ = new redBarEmbed();
         _loc2_.y = 0;
         _loc2_.width = MysteryBoxSelectModal.modalWidth - 5;
         _loc2_.height = MysteryBoxSelectModal.aMysteryBoxHeight - 8 + 5;
         _loc2_.alpha = 0;
         addChild(_loc2_);
         this.mbi = param1;
         this.quantity_ = 1;
         this.title = this.getText(this.mbi.title,74,20,18,true);
         this.title.textChanged.addOnce(this.updateTextPosition);
         addChild(this.title);
         this.addNewText();
         this.buyButton = new LegacyBuyButton("",16,0,Currency.INVALID,false,this.mbi.isOnSale());
         if(this.mbi.unitsLeft == 0)
         {
            this.buyButton.setText(LineBuilder.getLocalizedStringFromKey("MysteryBoxError.soldOutButton"));
         }
         else if(this.mbi.isOnSale())
         {
            this.buyButton.setPrice(this.mbi.saleAmount,this.mbi.saleCurrency);
         }
         else
         {
            this.buyButton.setPrice(this.mbi.priceAmount,this.mbi.priceCurrency);
         }
         this.buyButton.x = MysteryBoxSelectModal.modalWidth - 120;
         this.buyButton.y = 16;
         this.buyButton._width = 70;
         this.addSaleText();
         if(this.mbi.unitsLeft > 0 || this.mbi.unitsLeft == -1)
         {
            this.buyButton.addEventListener(MouseEvent.CLICK,this.onBoxBuy);
         }
         addChild(this.buyButton);
         this.iconImage = this.mbi.iconImage;
         this.infoImage = this.mbi.infoImage;
         if(this.iconImage == null)
         {
            this.mbi.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onImageLoadComplete);
         }
         else
         {
            this.addIconImageChild();
         }
         if(this.infoImage == null)
         {
            this.mbi.infoImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onInfoLoadComplete);
         }
         else
         {
            this.addInfoImageChild();
         }
         this.mbi.quantity = this.quantity_.toString();
         if(this.mbi.unitsLeft > 0 || this.mbi.unitsLeft == -1)
         {
            this.leftNavSprite = UIAssetsHelper.createLeftNevigatorIcon(UIAssetsHelper.LEFT_NEVIGATOR,3);
            this.leftNavSprite.x = this.buyButton.x + this.buyButton.width + 45;
            this.leftNavSprite.y = this.buyButton.y + this.buyButton.height / 2 - 2;
            this.leftNavSprite.addEventListener(MouseEvent.CLICK,this.onClick);
            addChild(this.leftNavSprite);
            this.rightNavSprite = UIAssetsHelper.createLeftNevigatorIcon(UIAssetsHelper.RIGHT_NEVIGATOR,3);
            this.rightNavSprite.x = this.buyButton.x + this.buyButton.width + 45;
            this.rightNavSprite.y = this.buyButton.y + this.buyButton.height / 2 - 16;
            this.rightNavSprite.addEventListener(MouseEvent.CLICK,this.onClick);
            addChild(this.rightNavSprite);
         }
         this.addUnitsLeftText();
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onRemoveHover);
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function updateTextPosition() : *
      {
         this.title.y = Math.round((this.redbar.height - (this.title.getTextHeight() + (this.title.textField.numLines == 1?8:10))) / 2);
         if((this.mbi.isNew() || this.mbi.isOnSale()) && this.title.textField.numLines == 2)
         {
            this.title.y = this.title.y + 6;
         }
      }
      
      public function updateContent() : *
      {
         if(this.left)
         {
            this.left.setStringBuilder(new LineBuilder().setParams(this.mbi.unitsLeft + " " + LineBuilder.getLocalizedStringFromKey("MysteryBoxSelectEntry.left")));
         }
      }
      
      private function addUnitsLeftText() : *
      {
         var _loc1_:uint = 0;
         var _loc2_:int = 0;
         if(this.mbi.unitsLeft >= 0)
         {
            _loc2_ = this.mbi.unitsLeft / this.mbi.totalUnits;
            if(_loc2_ <= 0.1)
            {
               _loc1_ = 16711680;
            }
            else if(_loc2_ <= 0.5)
            {
               _loc1_ = 16754944;
            }
            else
            {
               _loc1_ = 65280;
            }
            this.left = this.getText(this.mbi.unitsLeft + " left",20,46,11).setColor(_loc1_);
            addChild(this.left);
         }
      }
      
      private function markAsSold() : *
      {
         this.buyButton.setPrice(0,Currency.INVALID);
         this.buyButton.setText(LineBuilder.getLocalizedStringFromKey("MysteryBoxError.soldOutButton"));
         if(this.leftNavSprite && this.leftNavSprite.parent == this)
         {
            removeChild(this.leftNavSprite);
            this.leftNavSprite.removeEventListener(MouseEvent.CLICK,this.onClick);
         }
         if(this.rightNavSprite && this.rightNavSprite.parent == this)
         {
            removeChild(this.rightNavSprite);
            this.rightNavSprite.removeEventListener(MouseEvent.CLICK,this.onClick);
         }
      }
      
      private function onHover(param1:MouseEvent) : void
      {
         this.hoverState = true;
         this.addInfoImageChild();
      }
      
      private function onRemoveHover(param1:MouseEvent) : void
      {
         this.hoverState = false;
         this.removeInfoImageChild();
      }
      
      private function onClick(param1:MouseEvent) : *
      {
         switch(param1.currentTarget)
         {
            case this.rightNavSprite:
               if(this.quantity_ == 1)
               {
                  this.quantity_ = this.quantity_ + 4;
               }
               else if(this.quantity_ < 10)
               {
                  this.quantity_ = this.quantity_ + 5;
               }
               break;
            case this.leftNavSprite:
               if(this.quantity_ == 10)
               {
                  this.quantity_ = this.quantity_ - 5;
               }
               else if(this.quantity_ > 1)
               {
                  this.quantity_ = this.quantity_ - 4;
               }
         }
         this.mbi.quantity = this.quantity_.toString();
         if(this.mbi.isOnSale())
         {
            this.buyButton.setPrice(this.mbi.saleAmount * this.quantity_,this.mbi.saleCurrency);
         }
         else
         {
            this.buyButton.setPrice(this.mbi.priceAmount * this.quantity_,this.mbi.priceCurrency);
         }
      }
      
      private function addNewText() : void
      {
         if(this.mbi.isNew() && !this.mbi.isOnSale())
         {
            this.newText = this.getText(this.newString,74,0).setColor(16768512);
            addChild(this.newText);
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Number = 1.05 + 0.05 * Math.sin(getTimer() / 200);
         if(this.sale)
         {
            this.sale.scaleX = _loc2_;
            this.sale.scaleY = _loc2_;
         }
         if(this.newText)
         {
            this.newText.scaleX = _loc2_;
            this.newText.scaleY = _loc2_;
         }
         if(this.mbi.unitsLeft == 0 && !this.soldOut)
         {
            this.soldOut = true;
            this.markAsSold();
         }
      }
      
      private function addSaleText() : void
      {
         var _loc1_:LineBuilder = null;
         var _loc2_:TextFieldDisplayConcrete = null;
         var _loc3_:TextFieldDisplayConcrete = null;
         if(this.mbi.isOnSale())
         {
            this.sale = this.getText(this.onSaleString,74,0).setColor(65280);
            addChild(this.sale);
            _loc1_ = this.mbi.getSaleTimeLeftStringBuilder();
            _loc2_ = this.getText("",this.buyButton.x,this.buyButton.y + this.buyButton.height + 10,10).setColor(16711680);
            _loc2_.setStringBuilder(_loc1_);
            addChild(_loc2_);
            _loc3_ = this.getText(LineBuilder.getLocalizedStringFromKey("MysteryBoxSelectEntry.was") + " " + this.mbi.priceAmount + " " + this.mbi.currencyName,this.buyButton.x,this.buyButton.y - 14,10).setColor(16711680);
            addChild(_loc3_);
         }
      }
      
      private function onImageLoadComplete(param1:Event) : void
      {
         this.mbi.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onImageLoadComplete);
         this.iconImage = DisplayObject(this.mbi.loader);
         this.addIconImageChild();
      }
      
      private function onInfoLoadComplete(param1:Event) : void
      {
         this.mbi.infoImageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onInfoLoadComplete);
         this.infoImage = DisplayObject(this.mbi.infoImageLoader);
         this.addInfoImageChild();
      }
      
      public function getText(param1:String, param2:int, param3:int, param4:int = 12, param5:Boolean = false) : TextFieldDisplayConcrete
      {
         var _loc6_:TextFieldDisplayConcrete = new TextFieldDisplayConcrete().setSize(param4).setColor(16777215).setTextWidth(MysteryBoxSelectModal.modalWidth - 185);
         _loc6_.setBold(true);
         if(param5)
         {
            _loc6_.setStringBuilder(new StaticStringBuilder(param1));
         }
         else
         {
            _loc6_.setStringBuilder(new LineBuilder().setParams(param1));
         }
         _loc6_.setWordWrap(true);
         _loc6_.setMultiLine(true);
         _loc6_.setAutoSize(TextFieldAutoSize.LEFT);
         _loc6_.setHorizontalAlign(TextFormatAlign.LEFT);
         _loc6_.filters = [new DropShadowFilter(0,0,0)];
         _loc6_.x = param2;
         _loc6_.y = param3;
         return _loc6_;
      }
      
      private function addIconImageChild() : void
      {
         if(this.iconImage == null)
         {
            return;
         }
         this.iconImage.width = 58;
         this.iconImage.height = 58;
         this.iconImage.x = 14;
         if(this.mbi.unitsLeft != -1)
         {
            this.iconImage.y = -6;
         }
         else
         {
            this.iconImage.y = 1;
         }
         addChild(this.iconImage);
      }
      
      private function addInfoImageChild() : void
      {
         var _loc3_:Array = null;
         var _loc4_:ColorMatrixFilter = null;
         if(this.infoImage == null)
         {
            return;
         }
         var _loc1_:int = 8;
         this.infoImage.width = 291 - _loc1_;
         this.infoImage.height = 598 - _loc1_ * 2 - 2;
         var _loc2_:Point = this.globalToLocal(new Point(MysteryBoxSelectModal.getRightBorderX() + 1 + 14,2 + _loc1_));
         this.infoImage.x = _loc2_.x;
         this.infoImage.y = _loc2_.y;
         if(this.hoverState && !this.descriptionShowing)
         {
            this.descriptionShowing = true;
            addChild(this.infoImage);
            this.infoImageBorder = new PopupWindowBackground();
            this.infoImageBorder.draw(this.infoImage.width,this.infoImage.height + 2,PopupWindowBackground.TYPE_TRANSPARENT_WITHOUT_HEADER);
            this.infoImageBorder.x = this.infoImage.x;
            this.infoImageBorder.y = this.infoImage.y - 1;
            addChild(this.infoImageBorder);
            _loc3_ = [3.0742,-1.8282,-0.246,0,50,-0.9258,2.1718,-0.246,0,50,-0.9258,-1.8282,3.754,0,50,0,0,0,1,0];
            _loc4_ = new ColorMatrixFilter(_loc3_);
            this.redbar.filters = [_loc4_];
         }
      }
      
      private function removeInfoImageChild() : void
      {
         if(this.descriptionShowing)
         {
            removeChild(this.infoImageBorder);
            removeChild(this.infoImage);
            this.descriptionShowing = false;
            this.redbar.filters = [];
         }
      }
      
      private function onBoxBuy(param1:MouseEvent) : void
      {
         var _loc2_:OpenDialogSignal = null;
         var _loc3_:String = null;
         var _loc4_:Dialog = null;
         var _loc5_:MysteryBoxRollModal = null;
         var _loc6_:Boolean = false;
         if(this.mbi.unitsLeft != -1 && this.quantity_ > this.mbi.unitsLeft)
         {
            _loc2_ = StaticInjectorContext.getInjector().getInstance(OpenDialogSignal);
            _loc3_ = "";
            if(this.mbi.unitsLeft == 0)
            {
               _loc3_ = "MysteryBoxError.soldOutAll";
            }
            else
            {
               _loc3_ = LineBuilder.getLocalizedStringFromKey("MysteryBoxError.soldOutLeft",{
                  "left":this.mbi.unitsLeft,
                  "box":(this.mbi.unitsLeft == 1?LineBuilder.getLocalizedStringFromKey("MysteryBoxError.box"):LineBuilder.getLocalizedStringFromKey("MysteryBoxError.boxes"))
               });
            }
            _loc4_ = new Dialog("MysteryBoxRollModal.purchaseFailedString",_loc3_,"MysteryBoxRollModal.okString",null,null);
            _loc4_.addEventListener(Dialog.LEFT_BUTTON,this.onErrorOk);
            _loc2_.dispatch(_loc4_);
         }
         else
         {
            _loc5_ = new MysteryBoxRollModal(this.mbi,this.quantity_);
            _loc6_ = _loc5_.moneyCheckPass();
            if(_loc6_)
            {
               _loc5_.parentSelectModal = MysteryBoxSelectModal(parent.parent);
               _loc2_ = StaticInjectorContext.getInjector().getInstance(OpenDialogSignal);
               _loc2_.dispatch(_loc5_);
            }
         }
      }
      
      private function onErrorOk(param1:Event) : void
      {
         var _loc2_:OpenDialogSignal = null;
         _loc2_ = StaticInjectorContext.getInjector().getInstance(OpenDialogSignal);
         _loc2_.dispatch(new MysteryBoxSelectModal());
      }
   }
}
