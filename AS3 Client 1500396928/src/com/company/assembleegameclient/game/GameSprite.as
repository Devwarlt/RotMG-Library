package com.company.assembleegameclient.game
{
   import com.company.assembleegameclient.game.events.MoneyChangedEvent;
   import com.company.assembleegameclient.map.Map;
   import com.company.assembleegameclient.objects.GameObject;
   import com.company.assembleegameclient.objects.IInteractiveObject;
   import com.company.assembleegameclient.objects.Pet;
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.objects.Projectile;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.tutorial.Tutorial;
   import com.company.assembleegameclient.ui.GuildText;
   import com.company.assembleegameclient.ui.RankText;
   import com.company.assembleegameclient.ui.menu.PlayerMenu;
   import com.company.assembleegameclient.util.TextureRedrawer;
   import com.company.googleanalytics.GA;
   import com.company.util.CachingColorTransformer;
   import com.company.util.MoreColorUtil;
   import com.company.util.MoreObjectUtil;
   import com.company.util.PointUtil;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import kabam.lib.loopedprocs.LoopedCallback;
   import kabam.lib.loopedprocs.LoopedProcess;
   import kabam.rotmg.account.core.Account;
   import kabam.rotmg.appengine.api.AppEngineClient;
   import kabam.rotmg.arena.view.ArenaTimer;
   import kabam.rotmg.arena.view.ArenaWaveCounter;
   import kabam.rotmg.chat.view.Chat;
   import kabam.rotmg.constants.GeneralConstants;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.core.model.MapModel;
   import kabam.rotmg.core.model.PlayerModel;
   import kabam.rotmg.dailyLogin.signal.ShowDailyCalendarPopupSignal;
   import kabam.rotmg.dialogs.control.AddPopupToStartupQueueSignal;
   import kabam.rotmg.dialogs.control.FlushPopupStartupQueueSignal;
   import kabam.rotmg.dialogs.control.OpenDialogSignal;
   import kabam.rotmg.dialogs.model.DialogsModel;
   import kabam.rotmg.dialogs.model.PopupNamesConfig;
   import kabam.rotmg.game.view.CreditDisplay;
   import kabam.rotmg.game.view.GiftStatusDisplay;
   import kabam.rotmg.game.view.NewsModalButton;
   import kabam.rotmg.maploading.signals.HideMapLoadingSignal;
   import kabam.rotmg.maploading.signals.MapLoadedSignal;
   import kabam.rotmg.messaging.impl.GameServerConnectionConcrete;
   import kabam.rotmg.messaging.impl.incoming.MapInfo;
   import kabam.rotmg.news.model.NewsModel;
   import kabam.rotmg.news.view.NewsTicker;
   import kabam.rotmg.packages.services.PackageModel;
   import kabam.rotmg.packages.view.PackageButton;
   import kabam.rotmg.promotions.model.BeginnersPackageModel;
   import kabam.rotmg.promotions.signals.ShowBeginnersPackageSignal;
   import kabam.rotmg.promotions.view.BeginnersPackageButton;
   import kabam.rotmg.protip.signals.ShowProTipSignal;
   import kabam.rotmg.questrewards.view.QuestRewardsPanel;
   import kabam.rotmg.servers.api.Server;
   import kabam.rotmg.stage3D.Renderer;
   import kabam.rotmg.ui.UIUtils;
   import kabam.rotmg.ui.view.HUDView;
   import org.osflash.signals.Signal;
   import robotlegs.bender.framework.api.ILogger;
   
   public class GameSprite extends AGameSprite
   {
      
      protected static const PAUSED_FILTER:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.greyscaleFilterMatrix);
       
      
      public const monitor:Signal = new Signal(String,int);
      
      public const modelInitialized:Signal = new Signal();
      
      public const drawCharacterWindow:Signal = new Signal(Player);
      
      public var chatBox_:Chat;
      
      public var isNexus_:Boolean = false;
      
      public var idleWatcher_:IdleWatcher;
      
      public var rankText_:RankText;
      
      public var guildText_:GuildText;
      
      public var creditDisplay_:CreditDisplay;
      
      public var giftStatusDisplay:GiftStatusDisplay;
      
      public var newsModalButton:NewsModalButton;
      
      public var newsTicker:NewsTicker;
      
      public var arenaTimer:ArenaTimer;
      
      public var arenaWaveCounter:ArenaWaveCounter;
      
      public var mapModel:MapModel;
      
      public var beginnersPackageModel:BeginnersPackageModel;
      
      public var dialogsModel:DialogsModel;
      
      public var showBeginnersPackage:ShowBeginnersPackageSignal;
      
      public var openDailyCalendarPopupSignal:ShowDailyCalendarPopupSignal;
      
      public var openDialog:OpenDialogSignal;
      
      public var showPackage:Signal;
      
      public var packageModel:PackageModel;
      
      public var addToQueueSignal:AddPopupToStartupQueueSignal;
      
      public var flushQueueSignal:FlushPopupStartupQueueSignal;
      
      private var focus:GameObject;
      
      private var frameTimeSum_:int = 0;
      
      private var frameTimeCount_:int = 0;
      
      private var isGameStarted:Boolean;
      
      private var displaysPosY:uint = 4;
      
      private var currentPackage:DisplayObject;
      
      private var packageY:Number;
      
      public var chatPlayerMenu:PlayerMenu;
      
      public function GameSprite(param1:Server, param2:int, param3:Boolean, param4:int, param5:int, param6:ByteArray, param7:PlayerModel, param8:String, param9:Boolean)
      {
         this.showPackage = new Signal();
         this.currentPackage = new Sprite();
         super();
         this.model = param7;
         map = new Map(this);
         addChild(map);
         gsc_ = new GameServerConnectionConcrete(this,param1,param2,param3,param4,param5,param6,param8,param9);
         mui_ = new MapUserInput(this);
         this.chatBox_ = new Chat();
         this.chatBox_.list.addEventListener(MouseEvent.MOUSE_DOWN,this.onChatDown);
         this.chatBox_.list.addEventListener(MouseEvent.MOUSE_UP,this.onChatUp);
         addChild(this.chatBox_);
         this.idleWatcher_ = new IdleWatcher();
      }
      
      public static function dispatchMapLoaded(param1:MapInfo) : void
      {
         var _loc2_:MapLoadedSignal = StaticInjectorContext.getInjector().getInstance(MapLoadedSignal);
         _loc2_ && _loc2_.dispatch(param1);
      }
      
      private static function hidePreloader() : void
      {
         var _loc1_:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
         _loc1_ && _loc1_.dispatch();
      }
      
      public function onChatDown(param1:MouseEvent) : void
      {
         if(this.chatPlayerMenu != null)
         {
            this.removeChatPlayerMenu();
         }
         mui_.onMouseDown(param1);
      }
      
      public function onChatUp(param1:MouseEvent) : void
      {
         mui_.onMouseUp(param1);
      }
      
      override public function setFocus(param1:GameObject) : void
      {
         param1 = param1 || map.player_;
         this.focus = param1;
      }
      
      public function addChatPlayerMenu(param1:Player, param2:Number, param3:Number, param4:String = null, param5:Boolean = false, param6:Boolean = false) : void
      {
         this.removeChatPlayerMenu();
         this.chatPlayerMenu = new PlayerMenu();
         if(param4 == null)
         {
            this.chatPlayerMenu.init(this,param1);
         }
         else if(param6)
         {
            this.chatPlayerMenu.initDifferentServer(this,param4,param5,param6);
         }
         else
         {
            if(param4.length > 0 && (param4.charAt(0) == "#" || param4.charAt(0) == "*" || param4.charAt(0) == "@"))
            {
               return;
            }
            this.chatPlayerMenu.initDifferentServer(this,param4,param5);
         }
         addChild(this.chatPlayerMenu);
         this.chatPlayerMenu.x = param2;
         this.chatPlayerMenu.y = param3 - this.chatPlayerMenu.height;
      }
      
      public function removeChatPlayerMenu() : void
      {
         if(this.chatPlayerMenu != null && this.chatPlayerMenu.parent != null)
         {
            removeChild(this.chatPlayerMenu);
            this.chatPlayerMenu = null;
         }
      }
      
      override public function applyMapInfo(param1:MapInfo) : void
      {
         map.setProps(param1.width_,param1.height_,param1.name_,param1.background_,param1.allowPlayerTeleport_,param1.showDisplays_);
         dispatchMapLoaded(param1);
      }
      
      public function hudModelInitialized() : void
      {
         hudView = new HUDView();
         hudView.x = 600;
         addChild(hudView);
      }
      
      override public function initialize() : void
      {
         var _loc1_:Account = null;
         var _loc4_:ShowProTipSignal = null;
         map.initialize();
         this.modelInitialized.dispatch();
         if(this.evalIsNotInCombatMapArea())
         {
            this.showSafeAreaDisplays();
         }
         if(map.name_ == "Arena")
         {
            this.showTimer();
            this.showWaveCounter();
         }
         _loc1_ = StaticInjectorContext.getInjector().getInstance(Account);
         if(map.name_ == Map.NEXUS)
         {
            this.addToQueueSignal.dispatch(PopupNamesConfig.DAILY_LOGIN_POPUP,this.openDailyCalendarPopupSignal,-1,null);
            if(this.beginnersPackageModel.isBeginnerAvailable())
            {
               this.addToQueueSignal.dispatch(PopupNamesConfig.BEGINNERS_OFFER_POPUP,this.showBeginnersPackage,1,null);
            }
            else
            {
               this.addToQueueSignal.dispatch(PopupNamesConfig.PACKAGES_OFFER_POPUP,this.showPackage,1,null);
            }
            this.flushQueueSignal.dispatch();
         }
         this.isNexus_ = map.name_ == Map.NEXUS;
         if(this.isNexus_ || map.name_ == Map.DAILY_QUEST_ROOM)
         {
            this.creditDisplay_ = new CreditDisplay(this,true,true);
         }
         else
         {
            this.creditDisplay_ = new CreditDisplay(this);
         }
         this.creditDisplay_.x = 594;
         this.creditDisplay_.y = 0;
         addChild(this.creditDisplay_);
         var _loc2_:AppEngineClient = StaticInjectorContext.getInjector().getInstance(AppEngineClient);
         var _loc3_:Object = {
            "game_net_user_id":_loc1_.gameNetworkUserId(),
            "game_net":_loc1_.gameNetwork(),
            "play_platform":_loc1_.playPlatform()
         };
         MoreObjectUtil.addToObject(_loc3_,_loc1_.getCredentials());
         if(map.name_ != "Kitchen" && map.name_ != "Tutorial" && map.name_ != "Nexus Explanation" && Parameters.data_.watchForTutorialExit == true)
         {
            Parameters.data_.watchForTutorialExit = false;
            this.callTracking("rotmg.Marketing.track(\"tutorialComplete\")");
            _loc3_["fteStepCompleted"] = 9900;
            _loc2_.sendRequest("/log/logFteStep",_loc3_);
         }
         if(map.name_ == "Kitchen")
         {
            _loc3_["fteStepCompleted"] = 200;
            _loc2_.sendRequest("/log/logFteStep",_loc3_);
         }
         if(map.name_ == "Tutorial")
         {
            if(Parameters.data_.needsTutorial == true)
            {
               Parameters.data_.watchForTutorialExit = true;
               this.callTracking("rotmg.Marketing.track(\"install\")");
               _loc3_["fteStepCompleted"] = 100;
               _loc2_.sendRequest("/log/logFteStep",_loc3_);
            }
            this.startTutorial();
         }
         else if(map.name_ != "Arena" && map.name_ != "Kitchen" && map.name_ != "Nexus Explanation" && map.name_ != "Vault Explanation" && map.name_ != "Guild Explanation" && !this.evalIsNotInCombatMapArea() && Parameters.data_.showProtips)
         {
            _loc4_ = StaticInjectorContext.getInjector().getInstance(ShowProTipSignal);
            _loc4_ && _loc4_.dispatch();
         }
         if(map.name_ == "Daily Quest Room")
         {
            QuestRewardsPanel.checkQuests();
         }
         Parameters.save();
         hidePreloader();
      }
      
      private function showSafeAreaDisplays() : void
      {
         this.showRankText();
         this.showGuildText();
         this.setYAndPositionPackage();
         this.showGiftStatusDisplay();
         this.showNewsUpdate();
         this.showNewsTicker();
      }
      
      private function showTimer() : void
      {
         this.arenaTimer = new ArenaTimer();
         this.arenaTimer.y = 5;
         addChild(this.arenaTimer);
      }
      
      private function showWaveCounter() : void
      {
         this.arenaWaveCounter = new ArenaWaveCounter();
         this.arenaWaveCounter.y = 5;
         this.arenaWaveCounter.x = 5;
         addChild(this.arenaWaveCounter);
      }
      
      private function showNewsTicker() : void
      {
         this.newsTicker = new NewsTicker();
         this.newsTicker.x = 300 - this.newsTicker.width / 2;
         this.newsTicker.y = 5 + UIUtils.NOTIFICATION_SPACE;
         addChild(this.newsTicker);
      }
      
      private function showGiftStatusDisplay() : void
      {
         this.giftStatusDisplay = new GiftStatusDisplay();
         this.giftStatusDisplay.x = 6;
         this.giftStatusDisplay.y = this.displaysPosY + 2;
         this.displaysPosY = this.displaysPosY + UIUtils.NOTIFICATION_SPACE;
         addChild(this.giftStatusDisplay);
      }
      
      private function showNewsUpdate(param1:Boolean = true) : void
      {
         var _loc4_:NewsModalButton = null;
         var _loc2_:ILogger = StaticInjectorContext.getInjector().getInstance(ILogger);
         var _loc3_:NewsModel = StaticInjectorContext.getInjector().getInstance(NewsModel);
         _loc2_.debug("NEWS UPDATE -- making button");
         if(_loc3_.hasValidModalNews())
         {
            _loc2_.debug("NEWS UPDATE -- making button - ok");
            _loc4_ = new NewsModalButton();
            _loc4_.x = 6;
            _loc4_.y = 92;
            if(param1)
            {
               this.displaysPosY = this.displaysPosY + UIUtils.NOTIFICATION_SPACE;
            }
            if(this.newsModalButton != null)
            {
               removeChild(this.newsModalButton);
            }
            this.newsModalButton = _loc4_;
            addChild(this.newsModalButton);
         }
      }
      
      public function refreshNewsUpdateButton() : void
      {
         var _loc1_:ILogger = StaticInjectorContext.getInjector().getInstance(ILogger);
         _loc1_.debug("NEWS UPDATE -- refreshing button, update noticed");
         this.showNewsUpdate(false);
      }
      
      private function setYAndPositionPackage() : void
      {
         this.packageY = this.displaysPosY + 2;
         this.displaysPosY = this.displaysPosY + UIUtils.NOTIFICATION_SPACE;
         this.positionPackage();
      }
      
      private function positionPackage() : void
      {
         this.currentPackage.x = 6;
         this.currentPackage.y = this.packageY;
      }
      
      public function showBeginnersButtonIfSafe() : void
      {
         if(this.evalIsNotInCombatMapArea())
         {
            this.addAndPositionPackage(new BeginnersPackageButton());
         }
      }
      
      public function showPackageButtonIfSafe() : void
      {
         if(this.evalIsNotInCombatMapArea())
         {
            this.addAndPositionPackage(new PackageButton());
         }
      }
      
      private function addAndPositionPackage(param1:DisplayObject) : void
      {
         this.currentPackage = param1;
         addChild(this.currentPackage);
         this.positionPackage();
      }
      
      private function showGuildText() : void
      {
         this.guildText_ = new GuildText("",-1);
         this.guildText_.x = 64;
         this.guildText_.y = 6;
         addChild(this.guildText_);
      }
      
      private function showRankText() : void
      {
         this.rankText_ = new RankText(-1,true,false);
         this.rankText_.x = 8;
         this.rankText_.y = this.displaysPosY;
         this.displaysPosY = this.displaysPosY + UIUtils.NOTIFICATION_SPACE;
         addChild(this.rankText_);
      }
      
      private function callTracking(param1:String) : void
      {
         if(ExternalInterface.available == false)
         {
            return;
         }
         try
         {
            ExternalInterface.call(param1);
            return;
         }
         catch(err:Error)
         {
            return;
         }
      }
      
      private function startTutorial() : void
      {
         tutorial_ = new Tutorial(this);
         addChild(tutorial_);
      }
      
      private function updateNearestInteractive() : void
      {
         var _loc4_:Number = NaN;
         var _loc7_:GameObject = null;
         var _loc8_:IInteractiveObject = null;
         if(!map || !map.player_)
         {
            return;
         }
         var _loc1_:Player = map.player_;
         var _loc2_:Number = GeneralConstants.MAXIMUM_INTERACTION_DISTANCE;
         var _loc3_:IInteractiveObject = null;
         var _loc5_:Number = _loc1_.x_;
         var _loc6_:Number = _loc1_.y_;
         for each(_loc7_ in map.goDict_)
         {
            _loc8_ = _loc7_ as IInteractiveObject;
            if(_loc8_ && (!(_loc8_ is Pet) || this.map.isPetYard))
            {
               if(Math.abs(_loc5_ - _loc7_.x_) < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE || Math.abs(_loc6_ - _loc7_.y_) < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE)
               {
                  _loc4_ = PointUtil.distanceXY(_loc7_.x_,_loc7_.y_,_loc5_,_loc6_);
                  if(_loc4_ < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE && _loc4_ < _loc2_)
                  {
                     _loc2_ = _loc4_;
                     _loc3_ = _loc8_;
                  }
               }
            }
         }
         this.mapModel.currentInteractiveTarget = _loc3_;
      }
      
      private function isPetMap() : Boolean
      {
         return true;
      }
      
      public function connect() : void
      {
         if(!this.isGameStarted)
         {
            this.isGameStarted = true;
            Renderer.inGame = true;
            gsc_.connect();
            this.idleWatcher_.start(this);
            lastUpdate_ = getTimer();
            stage.addEventListener(MoneyChangedEvent.MONEY_CHANGED,this.onMoneyChanged);
            stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            LoopedProcess.addProcess(new LoopedCallback(100,this.updateNearestInteractive));
         }
      }
      
      public function disconnect() : void
      {
         if(this.isGameStarted)
         {
            this.isGameStarted = false;
            Renderer.inGame = false;
            this.idleWatcher_.stop();
            stage.removeEventListener(MoneyChangedEvent.MONEY_CHANGED,this.onMoneyChanged);
            stage.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            LoopedProcess.destroyAll();
            contains(map) && removeChild(map);
            map.dispose();
            CachingColorTransformer.clear();
            TextureRedrawer.clearCache();
            Projectile.dispose();
            gsc_.disconnect();
         }
      }
      
      private function onMoneyChanged(param1:Event) : void
      {
         gsc_.checkCredits();
      }
      
      override public function evalIsNotInCombatMapArea() : Boolean
      {
         return map.name_ == Map.NEXUS || map.name_ == Map.VAULT || map.name_ == Map.GUILD_HALL || map.name_ == Map.CLOTH_BAZAAR || map.name_ == Map.NEXUS_EXPLANATION || map.name_ == Map.DAILY_QUEST_ROOM;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc7_:Number = NaN;
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - lastUpdate_;
         if(this.idleWatcher_.update(_loc3_))
         {
            closed.dispatch();
            return;
         }
         LoopedProcess.runProcesses(_loc2_);
         this.frameTimeSum_ = this.frameTimeSum_ + _loc3_;
         this.frameTimeCount_ = this.frameTimeCount_ + 1;
         if(this.frameTimeSum_ > 300000)
         {
            _loc7_ = int(Math.round(1000 * this.frameTimeCount_ / this.frameTimeSum_));
            GA.global().trackEvent("performance","frameRate",map.name_,_loc7_);
            this.frameTimeCount_ = 0;
            this.frameTimeSum_ = 0;
         }
         var _loc4_:int = getTimer();
         map.update(_loc2_,_loc3_);
         this.monitor.dispatch("Map.update",getTimer() - _loc4_);
         camera_.update(_loc3_);
         var _loc5_:Player = map.player_;
         if(this.focus)
         {
            camera_.configureCamera(this.focus,!!_loc5_?Boolean(_loc5_.isHallucinating()):false);
            map.draw(camera_,_loc2_);
         }
         if(_loc5_ != null)
         {
            this.creditDisplay_.draw(_loc5_.credits_,_loc5_.fame_,_loc5_.tokens_);
            this.drawCharacterWindow.dispatch(_loc5_);
            if(this.evalIsNotInCombatMapArea())
            {
               this.rankText_.draw(_loc5_.numStars_);
               this.guildText_.draw(_loc5_.guildName_,_loc5_.guildRank_);
            }
            if(_loc5_.isPaused())
            {
               map.filters = [PAUSED_FILTER];
               hudView.filters = [PAUSED_FILTER];
               map.mouseEnabled = false;
               map.mouseChildren = false;
               hudView.mouseEnabled = false;
               hudView.mouseChildren = false;
            }
            else if(map.filters.length > 0)
            {
               map.filters = [];
               hudView.filters = [];
               map.mouseEnabled = true;
               map.mouseChildren = true;
               hudView.mouseEnabled = true;
               hudView.mouseChildren = true;
            }
            moveRecords_.addRecord(_loc2_,_loc5_.x_,_loc5_.y_);
         }
         lastUpdate_ = _loc2_;
         var _loc6_:int = getTimer() - _loc2_;
         this.monitor.dispatch("GameSprite.loop",_loc6_);
      }
      
      public function showPetToolTip(param1:Boolean) : void
      {
      }
   }
}
