package kabam.rotmg.application.model
{
   import flash.net.LocalConnection;
   import flash.system.Security;
   
   public class DomainModel
   {
       
      
      private const LOCALHOST:String = "localhost";
      
      private var PRODUCTION_WHITELIST:Array;
      
      private var TESTING_WHITELIST:Array;
      
      private var TESTING2_WHITELIST:Array;
      
      private var TRANSLATION_WHITELIST:Array;
      
      private var WHITELIST:Array;
      
      [Inject]
      public var client:PlatformModel;
      
      private var localDomain:String;
      
      public function DomainModel()
      {
         super();
         this.PRODUCTION_WHITELIST = ["www.realmofthemadgod.com","realmofthemadgodhrd.appspot.com","realmofthemadgod.appspot.com"];
         this.TESTING_WHITELIST = ["testing.realmofthemadgod.com","rotmgtesting.appspot.com","rotmghrdtesting.appspot.com"];
         this.TESTING2_WHITELIST = ["realmtesting2.appspot.com"];
         this.TRANSLATION_WHITELIST = ["xlate.kabam.com"];
         this.WHITELIST = this.PRODUCTION_WHITELIST.concat(this.TESTING_WHITELIST).concat(this.TRANSLATION_WHITELIST).concat(this.TESTING2_WHITELIST);
      }
      
      public function applyDomainSecurity() : void
      {
         var _loc1_:String = null;
         for each(_loc1_ in this.WHITELIST)
         {
            Security.allowDomain(_loc1_);
         }
      }
      
      public function isLocalDomainValid() : Boolean
      {
         return this.client.isDesktop() || this.isLocalDomainInWhiteList();
      }
      
      public function isLocalDomainProduction() : Boolean
      {
         var _loc1_:String = this.getLocalDomain();
         return this.PRODUCTION_WHITELIST.indexOf(_loc1_) != -1;
      }
      
      private function isLocalDomainInWhiteList() : Boolean
      {
         var _loc3_:String = null;
         var _loc1_:String = this.getLocalDomain();
         var _loc2_:* = _loc1_ == this.LOCALHOST;
         for each(_loc3_ in this.WHITELIST)
         {
            _loc2_ = Boolean(_loc2_ || _loc1_ == _loc3_);
         }
         return _loc2_;
      }
      
      private function getLocalDomain() : String
      {
         return this.localDomain = this.localDomain || new LocalConnection().domain;
      }
   }
}
