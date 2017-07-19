package kabam.rotmg.application.impl
{
   import com.company.assembleegameclient.parameters.Parameters;
   import kabam.rotmg.application.api.ApplicationSetup;
   
   public class Testing2Setup implements ApplicationSetup
   {
       
      
      private var SERVER:String;
      
      private var UNENCRYPTED:String;
      
      private var ENCRYPTED:String;
      
      private var ANALYTICS:String;
      
      private var BUILD_LABEL:String;
      
      public function Testing2Setup()
      {
          this.SERVER = "realmtesting2.appspot.com";
          this.UNENCRYPTED = "http://" + this.SERVER;
          this.ENCRYPTED = "https://" + this.SERVER;
          this.ANALYTICS = "UA-11236645-6";
          this.BUILD_LABEL = "<font color=\'#FF0000\'>TESTING 2 </font> #{VERSION}";
         super();
      }
      
      public function getAppEngineUrl(param1:Boolean = false) : String
      {
         return !!param1?this.UNENCRYPTED:this.ENCRYPTED;
      }
      
      public function getAnalyticsCode() : String
      {
         return this.ANALYTICS;
      }
      
      public function getBuildLabel() : String
      {
         var _loc1_:String = Parameters.BUILD_VERSION + "." + Parameters.MINOR_VERSION;
         return this.BUILD_LABEL.replace("{VERSION}",_loc1_);
      }
      
      public function useLocalTextures() : Boolean
      {
         return true;
      }
      
      public function isToolingEnabled() : Boolean
      {
         return true;
      }
      
      public function isGameLoopMonitored() : Boolean
      {
         return true;
      }
      
      public function areErrorsReported() : Boolean
      {
         return false;
      }
      
      public function useProductionDialogs() : Boolean
      {
         return true;
      }
      
      public function areDeveloperHotkeysEnabled() : Boolean
      {
         return false;
      }
      
      public function isDebug() : Boolean
      {
         return false;
      }
   }
}
