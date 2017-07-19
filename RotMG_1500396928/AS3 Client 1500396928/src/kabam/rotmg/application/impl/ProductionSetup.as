package kabam.rotmg.application.impl
{
   import com.company.assembleegameclient.parameters.Parameters;
   import kabam.rotmg.application.api.ApplicationSetup;
   
   public class ProductionSetup implements ApplicationSetup
   {
       
      
      private var SERVER:String;
      
      private var UNENCRYPTED:String;
      
      private var ENCRYPTED:String;
      
      private var ANALYTICS:String;
      
      private var BUILD_LABEL:String;
      
      public function ProductionSetup()
      {
          this.SERVER = "realmofthemadgodhrd.appspot.com";
          this.UNENCRYPTED = "http://" + this.SERVER;
          this.ENCRYPTED = "https://" + this.SERVER;
          this.ANALYTICS = "UA-11236645-4";
          this.BUILD_LABEL = "RotMG #{VERSION}.{MINOR}";
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
         return this.BUILD_LABEL.replace("{VERSION}",Parameters.BUILD_VERSION).replace("{MINOR}",Parameters.MINOR_VERSION);
      }
      
      public function useLocalTextures() : Boolean
      {
         return false;
      }
      
      public function isToolingEnabled() : Boolean
      {
         return false;
      }
      
      public function isGameLoopMonitored() : Boolean
      {
         return false;
      }
      
      public function useProductionDialogs() : Boolean
      {
         return true;
      }
      
      public function areErrorsReported() : Boolean
      {
         return false;
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
