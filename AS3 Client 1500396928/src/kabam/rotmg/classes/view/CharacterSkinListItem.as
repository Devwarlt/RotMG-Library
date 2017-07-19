package kabam.rotmg.classes.view
{
   import com.company.assembleegameclient.util.Currency;
   import com.company.util.MoreColorUtil;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.DropShadowFilter;
   import flash.geom.ColorTransform;
   import flash.text.TextFieldAutoSize;
   import kabam.rotmg.classes.model.CharacterSkin;
   import kabam.rotmg.classes.model.CharacterSkinState;
   import kabam.rotmg.text.model.TextKey;
   import kabam.rotmg.text.view.TextFieldDisplayConcrete;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
   import kabam.rotmg.text.view.stringBuilder.StringBuilder;
   import kabam.rotmg.util.components.RadioButton;
   import kabam.rotmg.util.components.api.BuyButton;
   import org.osflash.signals.Signal;
   import org.osflash.signals.natives.NativeMappedSignal;
   
   public class CharacterSkinListItem extends Sprite
   {
      
      public static const WIDTH:int = 420;
      
      public static const PADDING:int = 16;
      
      public static const HEIGHT:int = 60;
      
      private static const HIGHLIGHTED_COLOR:uint = 8092539;
      
      private static const AVAILABLE_COLOR:uint = 5921370;
      
      private static const LOCKED_COLOR:uint = 2631720;
       
      
      private const grayscaleMatrix:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.greyscaleFilterMatrix);

      private var background:Shape;

      private var skinContainer:Sprite;

      private var nameText:TextFieldDisplayConcrete;

      private var selectionButton:RadioButton;

      private var lock:Bitmap;

      private var lockText:TextFieldDisplayConcrete;

      private var buyButtonContainer:Sprite;

      private var limitedBanner:CharacterSkinLimitedBanner;

      public var buy:Signal;
      
      public const over:Signal = new Signal();
      
      public const out:Signal = new Signal();
      
      public var selected:Signal;
      
      private var model:CharacterSkin;
      
      private var state:CharacterSkinState;
      
      private var isSelected:Boolean = false;
      
      private var skinIcon:Bitmap;
      
      private var buyButton:BuyButton;
      
      private var isOver:Boolean;
      
      public function CharacterSkinListItem()
      {
         this.background = this.makeBackground();
         this.skinContainer = this.makeSkinContainer();
         this.nameText = this.makeNameText();
         this.selectionButton = this.makeSelectionButton();
         this.lock = this.makeLock();
         this.lockText = this.makeLockText();
         this.buyButtonContainer = this.makeBuyButtonContainer();
         this.limitedBanner = this.makeLimitedBanner();
         this.buy = new NativeMappedSignal(this.buyButtonContainer,MouseEvent.CLICK);
         this.selected = this.selectionButton.changed;
         this.state = CharacterSkinState.NULL;
         super();
      }
      
      private function makeBackground() : Shape
      {
         var _loc1_:Shape = new Shape();
         this.drawBackground(_loc1_.graphics,WIDTH);
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeSkinContainer() : Sprite
      {
         var _loc1_:Sprite = null;
         _loc1_ = new Sprite();
         _loc1_.x = 4;
         _loc1_.y = 4;
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeNameText() : TextFieldDisplayConcrete
      {
         var _loc1_:TextFieldDisplayConcrete = null;
         _loc1_ = new TextFieldDisplayConcrete().setSize(18).setColor(16777215).setBold(true);
         _loc1_.x = 60;
         _loc1_.setTextWidth(140);
         _loc1_.setWordWrap(true);
         _loc1_.setMultiLine(true);
         _loc1_.setAutoSize(TextFieldAutoSize.LEFT);
         _loc1_.filters = [new DropShadowFilter(0,0,0,1,8,8)];
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeLockText() : TextFieldDisplayConcrete
      {
         var _loc1_:TextFieldDisplayConcrete = new TextFieldDisplayConcrete().setSize(14).setColor(16777215);
         _loc1_.setTextWidth(190);
         _loc1_.setWordWrap(true);
         _loc1_.setMultiLine(true);
         _loc1_.setAutoSize(TextFieldAutoSize.LEFT);
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeSelectionButton() : RadioButton
      {
         var _loc1_:RadioButton = null;
         _loc1_ = new RadioButton();
         _loc1_.setSelected(false);
         _loc1_.x = 1 + WIDTH - _loc1_.width - 15;
         _loc1_.y = 1 + HEIGHT / 2 - _loc1_.height / 2;
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeLock() : Bitmap
      {
         var _loc1_:Bitmap = new Bitmap();
         _loc1_.scaleX = 2;
         _loc1_.scaleY = 2;
         _loc1_.visible = false;
         addChild(_loc1_);
         return _loc1_;
      }
      
      public function setLockIcon(param1:BitmapData) : void
      {
         this.lock.bitmapData = param1;
         this.lock.x = this.lockText.x - this.lock.width - 5;
         this.lock.y = HEIGHT / 2 - this.lock.height * 0.5;
      }
      
      private function makeBuyButtonContainer() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.x = WIDTH - PADDING;
         _loc1_.y = PADDING;
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeLimitedBanner() : CharacterSkinLimitedBanner
      {
         var _loc1_:CharacterSkinLimitedBanner = null;
         _loc1_ = new CharacterSkinLimitedBanner();
         _loc1_.readyForPositioning.addOnce(this.setLimitedBannerVisibility);
         _loc1_.y = -1;
         _loc1_.visible = false;
         addChild(_loc1_);
         return _loc1_;
      }
      
      public function setBuyButton(param1:BuyButton) : void
      {
         this.buyButton = param1;
         param1.readyForPlacement.add(this.onReadyForPlacement);
         this.model && this.setCost();
         this.buyButtonContainer.addChild(param1);
         param1.x = -param1.width;
         this.buyButtonContainer.visible = this.state == CharacterSkinState.PURCHASABLE;
         this.setLimitedBannerVisibility();
      }
      
      private function onReadyForPlacement() : void
      {
         this.buyButton.x = -this.buyButton.width;
      }
      
      public function setSkin(param1:Bitmap) : void
      {
         this.skinIcon && this.skinContainer.removeChild(this.skinIcon);
         this.skinIcon = param1;
         this.skinIcon && this.skinContainer.addChild(this.skinIcon);
      }
      
      public function getModel() : CharacterSkin
      {
         return this.model;
      }
      
      public function setModel(param1:CharacterSkin) : void
      {
         this.model && this.model.changed.remove(this.onModelChanged);
         this.model = param1;
         this.model && this.model.changed.add(this.onModelChanged);
         this.onModelChanged(this.model);
         addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
      }
      
      private function onModelChanged(param1:CharacterSkin) : void
      {
         this.state = !!this.model?this.model.getState():CharacterSkinState.NULL;
         this.updateName();
         this.updateState();
         this.buyButton && this.setCost();
         this.updateUnlockText();
         this.setLimitedBannerVisibility();
         this.setIsSelected(this.model && this.model.getIsSelected());
      }
      
      public function getState() : CharacterSkinState
      {
         return this.state;
      }
      
      private function updateName() : void
      {
         this.nameText.setStringBuilder(new LineBuilder().setParams(!!this.model?this.model.name:""));
         this.nameText.textChanged.addOnce(this.alignName);
      }
      
      private function alignName() : void
      {
         this.nameText.y = HEIGHT / 2 - this.nameText.height / 2;
      }
      
      private function updateState() : void
      {
         this.setButtonVisibilities();
         this.updateBackground();
         this.setEventListeners();
         this.updateGrayFilter();
      }
      
      private function setLimitedBannerVisibility() : void
      {
         this.limitedBanner.visible = this.model && this.model.limited && this.state != CharacterSkinState.OWNED && this.state != CharacterSkinState.PURCHASING;
         this.limitedBanner.x = (this.state == CharacterSkinState.LOCKED || !this.buyButton?this.lock.x - 5:this.buyButtonContainer.x + this.buyButton.x - 15) - this.limitedBanner.width;
      }
      
      private function setButtonVisibilities() : void
      {
         var _loc1_:* = this.state == CharacterSkinState.OWNED;
         var _loc2_:* = this.state == CharacterSkinState.PURCHASABLE;
         var _loc3_:* = this.state == CharacterSkinState.PURCHASING;
         var _loc4_:* = this.state == CharacterSkinState.LOCKED;
         this.selectionButton.visible = _loc1_;
         this.buyButtonContainer && (this.buyButtonContainer.visible = _loc2_);
         this.lock.visible = _loc4_;
         this.lockText.visible = _loc4_ || _loc3_;
      }
      
      private function setEventListeners() : void
      {
         if(this.state == CharacterSkinState.OWNED)
         {
            this.addEventListeners();
         }
         else
         {
            this.removeEventListeners();
         }
      }
      
      private function setCost() : void
      {
         var _loc1_:int = !!this.model?int(this.model.cost):0;
         this.buyButton.setPrice(_loc1_,Currency.GOLD);
      }
      
      public function getIsSelected() : Boolean
      {
         return this.isSelected;
      }
      
      public function setIsSelected(param1:Boolean) : void
      {
         this.isSelected = param1 && this.state == CharacterSkinState.OWNED;
         this.selectionButton.setSelected(param1);
         this.updateBackground();
      }
      
      private function updateUnlockText() : void
      {
         if(this.model != null && this.model.unlockSpecial != null)
         {
            this.lockText.setStringBuilder(new StaticStringBuilder(this.model.unlockSpecial));
         }
         else
         {
            this.lockText.setStringBuilder(this.state == CharacterSkinState.PURCHASING?new LineBuilder().setParams(TextKey.PURCHASING_SKIN):this.makeUnlockTextStringBuilder());
         }
         this.lockText.textChanged.addOnce(this.alignText);
      }
      
      private function alignText() : void
      {
         this.lockText.y = HEIGHT / 2 - this.lockText.height / 2;
         this.setTextPosition(WIDTH);
      }
      
      private function makeUnlockTextStringBuilder() : StringBuilder
      {
         var _loc1_:LineBuilder = new LineBuilder();
         var _loc2_:String = !!this.model?this.model.unlockLevel.toString():"";
         return _loc1_.setParams(TextKey.UNLOCK_LEVEL_SKIN,{"level":_loc2_});
      }
      
      private function addEventListeners() : void
      {
         addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      public function removeEventListeners() : void
      {
         removeEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.setIsSelected(true);
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         this.isOver = true;
         this.updateBackground();
         this.over.dispatch();
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         this.isOver = false;
         this.updateBackground();
         this.out.dispatch();
      }
      
      private function updateBackground() : void
      {
         var _loc1_:ColorTransform = this.background.transform.colorTransform;
         _loc1_.color = this.getColor();
         this.background.transform.colorTransform = _loc1_;
      }
      
      private function getColor() : uint
      {
         if(this.state.isDisabled())
         {
            return LOCKED_COLOR;
         }
         if(this.isSelected || this.isOver)
         {
            return HIGHLIGHTED_COLOR;
         }
         return AVAILABLE_COLOR;
      }
      
      private function updateGrayFilter() : void
      {
         filters = this.state == CharacterSkinState.PURCHASING?[this.grayscaleMatrix]:[];
      }
      
      public function setWidth(param1:int) : void
      {
         this.buyButtonContainer.x = param1 - PADDING;
         this.setTextPosition(param1);
         this.selectionButton.x = param1 - this.selectionButton.width - 15;
         this.setLimitedBannerVisibility();
         this.drawBackground(this.background.graphics,param1);
      }
      
      private function setTextPosition(param1:int) : void
      {
         this.lockText.x = param1 - this.lockText.width - 4;
         this.lock.x = this.lockText.x - this.lock.width - 4;
      }
      
      private function drawBackground(param1:Graphics, param2:int) : void
      {
         param1.clear();
         param1.beginFill(AVAILABLE_COLOR);
         param1.drawRect(0,0,param2,HEIGHT);
         param1.endFill();
      }
   }
}
