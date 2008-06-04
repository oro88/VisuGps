﻿package fr.victorb.chart 
{
    import com.hexagonstar.util.debug.Debug;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import fr.victorb.component.BigThumb;
    import mx.controls.HSlider;
    import mx.controls.sliderClasses.Slider;
    import mx.core.UIComponent;
    
    /**
    * Collection of Charts
    * @author Victor Berchet
    */
    public class Charts extends UIComponent
    {
        private var charts:Array = new Array();
        private var sliders:Array = new Array();
        private var cursor:Sprite;    
        
        private const SLIDER_HEIGHT:int = 20;
            
        /**
         * Constructor
         */
        public function Charts() 
        {
            super();
            addEventListener(Event.RESIZE, doChartsLayout);
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
            addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, true);
            addEventListener(MouseEvent.CLICK, onMouseClick, true);
        }
        
        /**
         * Add a chart to the collection
         * @param	chart chart to be added
         */
        public function addChart(chart:Chart):void {
            charts.push(chart);
            addChild(chart);
            chart.x = 0;
            chart.y = SLIDER_HEIGHT;
            var slider:HSlider = new HSlider();
            slider.y = SLIDER_HEIGHT / 2;
            slider.x = 0;
            slider.minimum = 0;
            slider.maximum = 100;
            slider.liveDragging = true;
            slider.sliderThumbClass = BigThumb;
            slider.setStyle("fillColors", [ 0xFFFFFF, chart.getColor()]);
            slider.dataTipFormatFunction = function(value:int):String {return chart.getName() + " : " + value};
            slider.addEventListener(Event.CHANGE, onSliderChange);        
            sliders.push(slider);
            addChild(slider);
        }
        
        /**
         * Set the chart alphas and coreesponding slider values
         * @param	values Array of alphas for each of the serie
         */
        public function setChartsAlpha(values:Array):void {
            for (var i:int = 0; i < values.length; i++) {
                charts[i].setAlpha(values[i]);
                sliders[i].setThumbValueAt(0, values[i] * 100);
            }        
            doChartsLayout(null);
        }
        
        /**
         * Set the cursor horizontal position
         * @param	value cursor position (0...999)
         */
        public function setCursorPosition(value:int):void {
            if (cursor) {
                cursor.x = charts[0].xMin + (charts[0].xMax - charts[0].xMin) * value / 1000;            
            }
        }
        
        /**
         * Dispatch an event when the mouse click occur over a chart
         * @param	event
         */
        private function onMouseClick(event:MouseEvent):void {
            if (globalToContent(new Point(event.stageX, event.stageY)).y < SLIDER_HEIGHT) return;
            if (cursor) {
                var chartEvent:ChartEvent = new ChartEvent(ChartEvent.CLICK,
                                                          (cursor.x - charts[0].xMin) * 1000 / (charts[0].xMax - charts[0].xMin));
                dispatchEvent(chartEvent);                    
            }
        }

        /**
         * Dispatch an event when the mouse move over a chart
         * @param	event
         */        
        private function onMouseMove(event:MouseEvent):void {
            if (globalToContent(new Point(event.stageX, event.stageY)).y < SLIDER_HEIGHT) return;            
            if (cursor &&
                event.stageX >= charts[0].xMin &&
                event.stageX <= charts[0].xMax) {
                    cursor.x = event.stageX;
                    cursor.y = 0;
                    var chartEvent:ChartEvent = new ChartEvent(ChartEvent.MOVE,
                                                               (cursor.x - charts[0].xMin) * 1000 / (charts[0].xMax - charts[0].xMin));
                    dispatchEvent(chartEvent);                    
                }
        }

        /**
         * Dispatch an event when the mouse wheel move over a chart
         * @param	event
         */         
        private function onMouseWheel(event:MouseEvent):void {
            if (globalToContent(new Point(event.stageX, event.stageY)).y < SLIDER_HEIGHT) return;
            if (cursor) {
                var chartEvent:ChartEvent;
                if (event.delta < 0) {
                    chartEvent= new ChartEvent(ChartEvent.WHEEL_DOWN,
                                               (cursor.x - charts[0].xMin) * 1000 / (charts[0].xMax - charts[0].xMin));
                } else {
                    chartEvent = new ChartEvent(ChartEvent.WHEEL_UP,
                                                (cursor.x - charts[0].xMin) * 1000 / (charts[0].xMax - charts[0].xMin));               
                }
            dispatchEvent(chartEvent);                            
            }
        }        
        
        /**
         * Update the layout when the component is resized
         * @param	event
         */
        private function doChartsLayout(event:Event):void {    
            if (charts.length == 0) return
            
            var sliderWidth:int = width / charts.length;
            
            for (var i:int = 0; i < charts.length; i++) {
                charts[i].width = width;
                charts[i].height = height - SLIDER_HEIGHT;
                sliders[i].x = i * sliderWidth;
                sliders[i].width = sliderWidth;
                charts[i].draw();
            }
            
            if (cursor) removeChild(cursor);
            
            cursor = new Sprite();
            cursor.graphics.lineStyle(2, 0xffcc00);            
            cursor.graphics.moveTo(0, charts[0].yMin + SLIDER_HEIGHT);
            cursor.graphics.lineTo(0, charts[0].yMax + SLIDER_HEIGHT);            
            addChild(cursor);
        }
        
        /**
         * Update chart alphas when the slider are changed
         * @param	event
         */
        private function onSliderChange(event:Event):void {
            var slider:Object = event.target;
            
            for (var i:int = 0; i < sliders.length; i++) {
                if (sliders[i] == slider) {
                    charts[i].setAlpha(slider.value / 100);                
                    break;
                }
            }
            
        }
        
        
    }
    
}