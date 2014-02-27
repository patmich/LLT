package  
{
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.describeType;
	import flash.display.DisplayObject;
	import flash.display.MorphShape;
	import flash.system.Security;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	
	public class Main extends MovieClip 
	{
		private var _input:String;
		private var _output:String;
		
		public function Main() 
		{
			
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, Init); 
		}
		
		private function Init(invocation:InvokeEvent):void
		{
			_input = invocation.arguments[0];
			_output = invocation.arguments[1];
			 
			var loader:Loader = new Loader();
			loader.load(new URLRequest(_input));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
		}
		
		private function loaded(e:Event):void 
		{
			var loaderInfo:LoaderInfo = (e.target as LoaderInfo);
			loaderInfo.loader.removeEventListener(Event.COMPLETE, loaded);
			
			var definitions:Vector.<String> = loaderInfo.applicationDomain.getQualifiedDefinitionNames();
			for(var index in definitions)
			{
				var definition:Class = loaderInfo.applicationDomain.getDefinition(definitions[index]) as Class;
				var instance:Object = null;
				try 
				{
					instance = new definition();
				}
				catch(error:Error)
				{
					continue;
				}
				if(instance is flash.display.MovieClip)
				{
					var mc:flash.display.MovieClip = instance as MovieClip;
					var description:XML = flash.utils.describeType(definition);
					var entries:XML = <entries></entries>;
					trace(description);
					for(var key:String in description..variable) 
					{
						trace(description..variable.@type[key]);
						var type_ = description..variable.@type[key];
						var name_ = description..variable.@name[key];
	
						if(type_ == "EMSwfText")
						{
							var crDefinition = loaderInfo.applicationDomain.getDefinition(type_) as Class;
							var crDescription:XML = flash.utils.describeType(crDefinition);		
							var initEntry:XML = <{type_}></{type_}>;
							initEntry.appendChild(<Name>{name_}</Name>);
							initEntry.appendChild(<Frame>0</Frame>);
							var declaredBy = crDescription.factory.accessor.(@declaredBy == type_);
							for(var crKey:String in declaredBy) 
							{
								var currentName = declaredBy.@name[crKey];
								var access = declaredBy.@access[crKey];

								if(access == "readwrite" || access == "readonly")
								{
									var child:DisplayObject = mc.getChildByName(name_);
									var val:String = child[currentName].toString();
									var property:XML =  <{currentName}>{val}</{currentName}>
									initEntry.appendChild(property);
								}
							}
							entries.appendChild(initEntry);
						}
					}
					
					trace("entries " + entries.children().length());
					if(entries.children().length() > 0)
					{
						var fileStream:FileStream = new FileStream(); 
				
						var file:File = new File("file://" + _output + "/" + definitions[index] + ".xml");
						file.parent.createDirectory();

						fileStream.open(file, FileMode.WRITE); 
						fileStream.writeUTFBytes(entries)
						fileStream.close();
					}
				}	
			}
			
			NativeApplication.nativeApplication.exit();
		}
	}
}
