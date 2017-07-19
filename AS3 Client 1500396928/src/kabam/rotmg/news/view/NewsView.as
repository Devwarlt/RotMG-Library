package kabam.rotmg.news.view
{
   import flash.display.Sprite;
   import kabam.rotmg.news.model.NewsCellVO;
   
   public class NewsView extends Sprite
   {
       
      
      private const LARGE_CELL_WIDTH:Number = 306;
      
      private const LARGE_CELL_HEIGHT:Number = 194;
      
      private const SMALL_CELL_WIDTH:Number = 151;
      
      private const SMALL_CELL_HEIGHT:Number = 189;
      
      private const SPACER:Number = 4;
      
      private var cellOne:NewsCell;
      
      private var cellTwo:NewsCell;
      
      private var cellThree:NewsCell;
      
      public function NewsView()
      {
         this.cellOne = new NewsCell(this.LARGE_CELL_WIDTH,this.LARGE_CELL_HEIGHT);
         this.cellTwo = new NewsCell(this.SMALL_CELL_WIDTH,this.SMALL_CELL_HEIGHT);
         this.cellThree = new NewsCell(this.SMALL_CELL_WIDTH,this.SMALL_CELL_HEIGHT);
         super();
         this.tabChildren = false;
         this.addChildren();
         this.positionChildren();
      }
      
      private function addChildren() : void
      {
         addChild(this.cellOne);
         addChild(this.cellTwo);
         addChild(this.cellThree);
      }
      
      private function positionChildren() : void
      {
         this.cellTwo.y = this.LARGE_CELL_HEIGHT + this.SPACER;
         this.cellThree.x = this.SMALL_CELL_WIDTH + this.SPACER;
         this.cellThree.y = this.LARGE_CELL_HEIGHT + this.SPACER;
      }
      
      public function update(param1:Vector.<NewsCellVO>) : void
      {
         this.cellOne.init(param1[0]);
         this.cellTwo.init(param1[1]);
         this.cellThree.init(param1[2]);
         this.cellOne.load();
         this.cellTwo.load();
         this.cellThree.load();
      }
   }
}
