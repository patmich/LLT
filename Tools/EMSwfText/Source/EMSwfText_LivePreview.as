package  {
	
	import fl.core.UIComponent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.sampler.Sample;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.net.FileFilter;
	import flash.events.FocusEvent;
	import adobe.utils.MMExecute;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	
	public class EMSwfText_LivePreview extends UIComponent 
	{
		private var _textField : TextField;
		private var _textFormat : TextFormat;
		private var _content : String;
		private var _fontId : String;
		private var _previewStyle : Boolean;
		private var _fileReference : FileReference = new FileReference();
		
		
		[Inspectable(defaultValue="Text")]
		public function set Content(val:String) : void
		{
			_content = val;
			draw();
		}
		public function get Content() : String
		{
			return _content;
		}
		
		[Inspectable(defaultValue="12")]
		public function set Size(val:int) : void
		{
			_textFormat.size = val;
			draw();
		}
		public function get Size() : int
		{
			return _textFormat.size as int;
		}
		
		[Inspectable(type="Boolean", defaultValue="false", name="Preview Style")]
		public function set PreviewStyle(val:Boolean) : void
		{
			if(_previewStyle != val)
			{
				_previewStyle = val;
				if(_previewStyle)
				{
					_fileReference.addEventListener(Event.SELECT, OnSelect);
					_fileReference.addEventListener(Event.CANCEL, OnCancel);
					_fileReference.browse([new FileFilter("XML File (*.xml)", "*.xml")]);
				}
				else
				{
					_textField.filters = [];
					draw();
				}
			}
		}
		private function OnCancel(event:Event) : void
		{
			_fileReference.removeEventListener(Event.SELECT, OnSelect);
			_fileReference.removeEventListener(Event.CANCEL, OnCancel);
		}
		private function OnSelect(event:Event) : void
		{
			_fileReference.removeEventListener(Event.SELECT, OnSelect);
			_fileReference.removeEventListener(Event.SELECT, OnCancel);
			_fileReference.addEventListener(Event.COMPLETE, OnLoadComplete);
			_fileReference.load();
		}
		private function OnLoadComplete(event:Event) : void
		{
			_fileReference.removeEventListener(Event.COMPLETE, OnLoadComplete);
			
			EMSwfText_Rasterizer.Parse(XML(_fileReference.data.toString()), _textField, _textFormat);
			draw();
		}
		
		
		
		[Inspectable(type="String")]
		public function set FontId(val:String) : void
		{
		}
		public function get FontId() : String
		{
			return null;
		}
		
		public function EMText_LivePreview(w:Number = NaN, h:Number = NaN) 
		{
			configUI();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			_textField = new TextField();
			_textFormat = new TextFormat();	
	
			this.addChild(_textField);
			draw();
		}
		
		protected override function draw():void 
		{		
			super.draw();
			
			_textField.defaultTextFormat = _textFormat;
						
			if(_content != null)
			{
				_textField.text = _content;
			}
			else
			{
				_textField.text = "";
			}

			this.removeChild(_textField);
			this.addChild(_textField);
		}
	}
}
