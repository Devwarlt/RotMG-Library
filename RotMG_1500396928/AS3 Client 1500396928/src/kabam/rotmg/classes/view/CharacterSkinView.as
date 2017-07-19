package kabam.rotmg.classes.view
{
   import com.company.assembleegameclient.constants.ScreenTypes;
   import com.company.assembleegameclient.screens.AccountScreen;
   import com.company.assembleegameclient.screens.TitleMenuOption;
   import com.company.rotmg.graphics.ScreenGraphic;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.core.model.PlayerModel;
   import kabam.rotmg.game.view.CreditDisplay;
   import kabam.rotmg.text.view.TextFieldDisplayConcrete;
   import kabam.rotmg.ui.view.SignalWaiter;
   import kabam.rotmg.ui.view.components.ScreenBase;
   import org.osflash.signals.Signal;
   import org.osflash.signals.natives.NativeMappedSignal;
   
   public class CharacterSkinView extends Sprite
   {
       
      
      private var base:ScreenBase;
      
      private var account:AccountScreen;
      
      private var lines:Shape;
      
      private var creditsDisplay:CreditDisplay;
      
      private var graphic:ScreenGraphic;
      
      private var playBtn:TitleMenuOption;
      
      private var backBtn:TitleMenuOption;
      
      private var list:CharacterSkinListView;
      
      private var detail:ClassDetailView;
      
      public var play:Signal;
      
      public var back:Signal;
      
      public var waiter:SignalWaiter;
      
      public function CharacterSkinView()
      {
          this.base = this.makeScreenBase();
          this.account = this.makeAccountScreen();
          this.lines = this.makeLines();
          this.creditsDisplay = this.makeCreditDisplay();
          this.graphic = this.makeScreenGraphic();
          this.playBtn = this.makePlayButton();
          this.backBtn = this.makeBackButton();
          this.list = this.makeListView();
          this.detail = this.makeClassDetailView();
          play = new NativeMappedSignal(this.playBtn,MouseEvent.CLICK);
          back = new NativeMappedSignal(this.backBtn,MouseEvent.CLICK);
          waiter = this.makeSignalWaiter();
         super();
      }
      
      private function makeScreenBase() : ScreenBase
      {
         var _loc1_:ScreenBase = new ScreenBase();
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeAccountScreen() : AccountScreen
      {
         var _loc1_:AccountScreen = new AccountScreen();
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeCreditDisplay() : CreditDisplay
      {
         var _loc1_:CreditDisplay = null;
         _loc1_ = new CreditDisplay(null,true,true);
         var _loc2_:PlayerModel = StaticInjectorContext.getInjector().getInstance(PlayerModel);
         if(_loc2_ != null)
         {
            _loc1_.draw(_loc2_.getCredits(),_loc2_.getFame(),_loc2_.getTokens());
         }
         _loc1_.x = 800;
         _loc1_.y = 20;
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeLines() : Shape
      {
         var _loc1_:Shape = new Shape();
         _loc1_.graphics.clear();
         _loc1_.graphics.lineStyle(2,5526612);
         _loc1_.graphics.moveTo(0,105);
         _loc1_.graphics.lineTo(800,105);
         _loc1_.graphics.moveTo(346,105);
         _loc1_.graphics.lineTo(346,526);
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeScreenGraphic() : ScreenGraphic
      {
         var _loc1_:ScreenGraphic = new ScreenGraphic();
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makePlayButton() : TitleMenuOption
      {
         var _loc1_:TitleMenuOption = null;
         _loc1_ = new TitleMenuOption(ScreenTypes.PLAY,36,false);
         _loc1_.setAutoSize(TextFieldAutoSize.CENTER);
         _loc1_.setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
         _loc1_.x = 400 - _loc1_.width / 2;
         _loc1_.y = 550;
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeBackButton() : TitleMenuOption
      {
         var _loc1_:TitleMenuOption = null;
         _loc1_ = new TitleMenuOption(ScreenTypes.BACK,22,false);
         _loc1_.setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
         _loc1_.x = 30;
         _loc1_.y = 550;
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeListView() : CharacterSkinListView
      {
         var _loc1_:CharacterSkinListView = null;
         _loc1_ = new CharacterSkinListView();
         _loc1_.x = 351;
         _loc1_.y = 110;
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeClassDetailView() : ClassDetailView
      {
         var _loc1_:ClassDetailView = null;
         _loc1_ = new ClassDetailView();
         _loc1_.x = 5;
         _loc1_.y = 110;
         addChild(_loc1_);
         return _loc1_;
      }
      
      public function setPlayButtonEnabled(param1:Boolean) : void
      {
         if(!param1)
         {
            this.playBtn.deactivate();
         }
      }
      
      private function makeSignalWaiter() : SignalWaiter
      {
         var _loc1_:SignalWaiter = new SignalWaiter();
         _loc1_.push(this.playBtn.changed);
         _loc1_.complete.add(this.positionOptions);
         return _loc1_;
      }
      
      private function positionOptions() : void
      {
         this.playBtn.x = stage.stageWidth / 2;
      }
   }
}
