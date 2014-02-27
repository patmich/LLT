package  
{
	import flash.display.MovieClip;
	public class EMSwfText extends MovieClip 
	{
		private var _content:String;
		private var _size:int;
		private var _fontId:String;
		private var _maxCharCount:int;
		
		[Inspectable(defaultValue="Text")]
		public function set Content(val:String) : void
		{
			_content = val;
		}
		public function get Content() : String
		{
			return _content;
		}
		
		[Inspectable(defaultValue="12")]
		public function set Size(val:int) : void
		{
			_size = val;
		}
		public function get Size() : int
		{
			return _size;
		}
		
		[Inspectable(type="Boolean", defaultValue="false", name="Preview Style")]
		public function set PreviewStyle(val:Boolean) : void
		{
		}
		
		[Inspectable(type="String")]
		public function set FontId(val:String) : void
		{
			_fontId = val;
		}
		public function get FontId() : String
		{
			return _fontId;
		}
		
		[Inspectable(type="Int")]
		public function set MaxCharCount(val:int) : void
		{
			_maxCharCount = val;
		}
		public function get MaxCharCount() : int
		{
			return _maxCharCount;
		}
	}
}
