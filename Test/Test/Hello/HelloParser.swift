// Generated from Hello.g4 by ANTLR 4.5.1
import Antlr4

public class HelloParser: Parser {

	internal static var _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          for var i: Int = 0; i < HelloParser._ATN.getNumberOfDecisions(); i++ {
            decisionToDFA.append(DFA(HelloParser._ATN.getDecisionState(i)!, i))
           }
           return decisionToDFA
     }()
	internal let _sharedContextCache: PredictionContextCache = PredictionContextCache()
	public let T__0=1, ID=2, WS=3
	public let RULE_r = 0
	public static let ruleNames: [String] = [
		"r"
	]

	private static let _LITERAL_NAMES: [String?] = [
		nil, "'hello'"
	]
	private static let _SYMBOLIC_NAMES: [String?] = [
		nil, nil, "ID", "WS"
	]
	public static let VOCABULARY: Vocabulary = Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES)

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	//@Deprecated
	public let tokenNames: [String?]? = {
	    var tokenNames = [String?]()

		for  var i : Int = 0; i < _SYMBOLIC_NAMES.count; i++ {
			var name = VOCABULARY.getLiteralName(i)
			if name == nil {
				name = VOCABULARY.getSymbolicName(i)
			}

			if name == nil {
				name = "<INVALID>"
			}
			 tokenNames.append(name)
		}
		return tokenNames
	}()

	override
	public func getTokenNames() -> [String?]? {
		return tokenNames
	}


	override
	public func getGrammarFileName() -> String { return "Hello.g4" }

	override
	public func getRuleNames() -> [String] { return HelloParser.ruleNames }

	override
	public func getSerializedATN() -> String { return HelloParser._serializedATN }

	override
	public func getATN() -> ATN { return HelloParser._ATN }

	public override func getVocabulary() -> Vocabulary {
	        return HelloParser.VOCABULARY;
	}
	public override  init(_ input:TokenStream)throws {
	    RuntimeMetaData.checkVersion("4.5.1", RuntimeMetaData.VERSION)
		try super.init(input)
		_interp = ParserATNSimulator(self,HelloParser._ATN,HelloParser._decisionToDFA,_sharedContextCache)
	}
	public  class RContext: ParserRuleContext {
	    weak var host: HelloParser!
		public func ID() -> TerminalNode? { return getToken(host.ID, 0) }
		public convenience init(_ parent: ParserRuleContext?, _ invokingState: Int, _ host: HelloParser) {
			self.init(parent, invokingState)
			self.host = host
		}
		public override func getRuleIndex() -> Int { return host.RULE_r  }
		override
		public func enterRule(listener: ParseTreeListener) {
			if (listener is HelloListener) {
			 	(listener as! HelloListener).enterR(self)
			}
		}
		override
		public func exitRule(listener: ParseTreeListener) {
			if (listener is HelloListener) {
			 	(listener as! HelloListener).exitR(self)
			}
		}
		override
		public func accept<T>(visitor: ParseTreeVisitor<T>) -> T? {
			if ( visitor is HelloVisitor ){
			     return (visitor as! (HelloVisitor<T>)).visitR(self)
			}
			else {
			      return visitor.visitChildren(self)
			}
		}
	}

	public func r() throws -> RContext {
		var _localctx: RContext = RContext(_ctx, getState(),self)
		try enterRule(_localctx, 0,  RULE_r)
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(2)
		 	try match(T__0)
		 	setState(3)
		 	try match(ID)

		}
		catch ANTLRException.Recognition(let  re ) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}
		defer {
			try! exitRule()
		 }
		return _localctx
	}

   public static let _serializedATN : String = Utils.readFile2String( "HelloParserATN.json")
   public static let _ATN: ATN = ATNDeserializer().deserializeFromJson(_serializedATN)
}