/**
 * BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
 * 
 * Copyright (c) 2012 BigBlueButton Inc. and by respective authors (see below).
 *
 * This program is free software; you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 3.0 of the License, or (at your option) any later
 * version.
 * 
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
 *
 */
package org.bigbluebutton.core.managers
{
	import com.asfusion.mate.events.Dispatcher;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	import mx.utils.URLUtil;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getClassLogger;
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.core.model.Config;
	import org.bigbluebutton.main.events.ConfigLoadedEvent;
	import org.bigbluebutton.main.events.MeetingNotFoundEvent;
	import org.bigbluebutton.main.model.modules.ModuleDescriptor;
	import org.bigbluebutton.util.QueryStringParameters;
	
	public class ConfigManager2 {
		private static const LOGGER:ILogger = getClassLogger(ConfigManager2);      
    
        public static const CONFIG_XML:String = "bigbluebutton/api/configXML";
    
		private var _config:Config = null;
				
		public function loadConfig():void {
			var p:QueryStringParameters = new QueryStringParameters();
			p.collectParameters();
			var sessionToken:String = p.getParameter("sessionToken");
			
			var reqVars:URLVariables = new URLVariables();
			reqVars.sessionToken = sessionToken;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, handleComplete);
			
			var date:Date = new Date();
            var localeReqURL:String = buildRequestURL();
            trace("::loadConfig [{0}]", [localeReqURL]);
			
			trace(localeReqURL + " session=[" + sessionToken + "]"); 
			
			var request:URLRequest = new URLRequest(localeReqURL);
			request.method = URLRequestMethod.GET;
			request.data = reqVars;
			
			urlLoader.load(request);			
		}		
		
    private function buildRequestURL():String {
      var swfURL:String = FlexGlobals.topLevelApplication.url;
      var protocol:String = URLUtil.getProtocol(swfURL);
      var serverName:String = URLUtil.getServerNameWithPort(swfURL);        
      return protocol + "://" + serverName + "/" + CONFIG_XML;
    }
    
		private function handleComplete(e:Event):void{
      trace("handleComplete [{0}]", [new XML(e.target.data)]);
      
      var xml:XML = new XML(e.target.data)
	  var dispatcher:Dispatcher = new Dispatcher();
	  
      if (xml.returncode == "FAILED") {
        
        trace("Getting configXML failed [{0}]", [xml]);        
        
        dispatcher.dispatchEvent(new MeetingNotFoundEvent(xml.response.logoutURL));
      } else { 
        trace("Getting configXML passed [{0}]", [xml]);
        
		_config = new Config(new XML(e.target.data));
        
        trace("Initializing logging.");
        LogUtil.initLogging();
    
		dispatcher.dispatchEvent(new ConfigLoadedEvent()); 	
      }
		}
		
		public function get config():Config {
			return _config;
		}
		
		public function getModules():Dictionary {
			return _config.getModules();
		}
		
		public function getPortortTestHost():String {
			return _config.porttest.host;
		}
		
		public function getPortTestApplication():String {
			return _config.porttest.application;
		}
		
		public function getPortTestTimeout():int {
			return _config.porttest.timeout;
		}
		
		public function getModuleFor(name:String):ModuleDescriptor {
			return _config.getModuleFor(name);
		}
	}
}