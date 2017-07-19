package kabam.rotmg.news.model
{
   import com.company.assembleegameclient.parameters.Parameters;
   import kabam.rotmg.account.core.Account;
   import kabam.rotmg.news.controller.NewsButtonRefreshSignal;
   import kabam.rotmg.news.controller.NewsDataUpdatedSignal;
   import kabam.rotmg.news.view.NewsModalPage;
   
   public class NewsModel
   {
      
      private static const COUNT:int = 3;
      
      public static const MODAL_PAGE_COUNT:int = 4;
       
      
      [Inject]
      public var update:NewsDataUpdatedSignal;
      
      [Inject]
      public var updateNoParams:NewsButtonRefreshSignal;
      
      [Inject]
      public var account:Account;
      
      public var news:Vector.<NewsCellVO>;
      
      public var modalPages:Vector.<NewsModalPage>;
      
      public var modalPageData:Vector.<NewsCellVO>;
      
      private var inGameNews:Vector.<InGameNews>;
      
      public function NewsModel()
      {
         this.inGameNews = new Vector.<InGameNews>();
         super();
      }
      
      public function addInGameNews(param1:InGameNews) : void
      {
         if(this.isValidForPlatform(param1))
         {
            this.inGameNews.push(param1);
         }
         this.sortNews();
      }
      
      private function sortNews() : *
      {
         this.inGameNews.sort(function(param1:InGameNews, param2:InGameNews):*
         {
            if(param1.weight > param2.weight)
            {
               return -1;
            }
            if(param1.weight == param2.weight)
            {
               return 0;
            }
            return 1;
         });
      }
      
      public function markAsRead() : void
      {
         var _loc1_:InGameNews = this.getFirstNews();
         if(_loc1_ != null)
         {
            Parameters.data_["lastNewsKey"] = _loc1_.newsKey;
            Parameters.save();
         }
      }
      
      public function hasUpdates() : Boolean
      {
         var _loc1_:InGameNews = this.getFirstNews();
         if(_loc1_ == null || Parameters.data_["lastNewsKey"] == _loc1_.newsKey)
         {
            return false;
         }
         return true;
      }
      
      public function getFirstNews() : InGameNews
      {
         if(this.inGameNews && this.inGameNews.length > 0)
         {
            return this.inGameNews[0];
         }
         return null;
      }
      
      public function initNews() : void
      {
         this.news = new Vector.<NewsCellVO>(COUNT,true);
         var _loc1_:int = 0;
         while(_loc1_ < COUNT)
         {
            this.news[_loc1_] = new DefaultNewsCellVO(_loc1_);
            _loc1_++;
         }
      }
      
      public function updateNews(param1:Vector.<NewsCellVO>) : void
      {
         var _loc3_:NewsCellVO = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.initNews();
         var _loc2_:Vector.<NewsCellVO> = new Vector.<NewsCellVO>();
         this.modalPageData = new Vector.<NewsCellVO>(4,true);
         for each(_loc3_ in param1)
         {
            if(_loc3_.slot <= 3)
            {
               _loc2_.push(_loc3_);
            }
            else
            {
               _loc4_ = _loc3_.slot - 4;
               _loc5_ = _loc4_ + 1;
               this.modalPageData[_loc4_] = _loc3_;
               if(Parameters.data_["newsTimestamp" + _loc5_] != _loc3_.endDate)
               {
                  Parameters.data_["newsTimestamp" + _loc5_] = _loc3_.endDate;
                  Parameters.data_["hasNewsUpdate" + _loc5_] = true;
               }
            }
         }
         this.sortByPriority(_loc2_);
         this.update.dispatch(this.news);
         this.updateNoParams.dispatch();
      }
      
      private function sortByPriority(param1:Vector.<NewsCellVO>) : void
      {
         var _loc2_:NewsCellVO = null;
         for each(_loc2_ in param1)
         {
            if(this.isNewsTimely(_loc2_) && this.isValidForPlatformGlobal(_loc2_))
            {
               this.prioritize(_loc2_);
            }
         }
      }
      
      private function prioritize(param1:NewsCellVO) : void
      {
         var _loc2_:uint = param1.slot - 1;
         if(this.news[_loc2_])
         {
            param1 = this.comparePriority(this.news[_loc2_],param1);
         }
         this.news[_loc2_] = param1;
      }
      
      private function comparePriority(param1:NewsCellVO, param2:NewsCellVO) : NewsCellVO
      {
         return param1.priority < param2.priority?param1:param2;
      }
      
      private function isNewsTimely(param1:NewsCellVO) : Boolean
      {
         var _loc2_:Number = new Date().getTime();
         return param1.startDate < _loc2_ && _loc2_ < param1.endDate;
      }
      
      public function hasValidNews() : Boolean
      {
         return this.news[0] != null && this.news[1] != null && this.news[2] != null;
      }
      
      public function hasValidModalNews() : Boolean
      {
         return this.inGameNews.length > 0;
      }
      
      public function get numberOfNews() : int
      {
         return this.inGameNews.length;
      }
      
      public function getModalPage(param1:int) : NewsModalPage
      {
         var _loc2_:InGameNews = null;
         if(this.hasValidModalNews())
         {
            _loc2_ = this.inGameNews[param1 - 1];
            return new NewsModalPage(_loc2_.title,_loc2_.text);
         }
         return new NewsModalPage("No new information","Please check back later.");
      }
      
      private function isValidForPlatformGlobal(param1:NewsCellVO) : Boolean
      {
         var _loc2_:String = this.account.gameNetwork();
         return param1.networks.indexOf(_loc2_) != -1;
      }
      
      private function isValidForPlatform(param1:InGameNews) : Boolean
      {
         var _loc2_:String = this.account.gameNetwork();
         return param1.platform.indexOf(_loc2_) != -1;
      }
   }
}
