package com.company.assembleegameclient.mapeditor
{
   public class RegionChooser extends Chooser
   {
       
      
      public function RegionChooser()
      {
         var _loc1_:XML = null;
         var _loc2_:RegionElement = null;
         super(Layer.REGION);
         for each(_loc1_ in GroupDivider.GROUPS["Regions"])
         {
            _loc2_ = new RegionElement(_loc1_);
            addElement(_loc2_);
         }
      }
   }
}
