pref("extensions.alpheios.latin.usemhttpd", true);
pref("extensions.alpheios.latin.chromepkg","alpheios-latin");
pref("extensions.alpheios.latin.languagecode","la");
pref("extensions.alpheios.latin.base_unit","word");
pref("extensions.alpheios.latin.context_handler","grammarContext");
pref("extensions.alpheios.latin.methods.convert",'latinToAscii');
pref("extensions.alpheios.latin.methods.lexicon",'webservice');
pref("extensions.alpheios.latin.methods.startup",'loadLexIds');
pref("extensions.alpheios.latin.url.lexicon", 'http://localhost:8200');
pref("extensions.alpheios.latin.url.lexicon.request", "/latin?word=<WORD>");
pref("extensions.alpheios.latin.url.lexicon.timeout",5000);
pref("extensions.alpheios.latin.url.grammar",
     "chrome://alpheios-latin/content/alph-latin-grammar.xul");
pref("extensions.alpheios.latin.grammar.hotlinks",
     "alph-decl,alph-conj,alph-pofs,alph-mood,alph-case");
pref("extensions.alpheios.latin.popuptrigger",'dblclick');
pref("extensions.alpheios.latin.features.alpheios-inflect",true);
pref("extensions.alpheios.latin.features.alpheios-grammar",true);
pref("extensions.alpheios.latin.panels.use.defaults",true);
pref("extensions.alpheios.latin.dictionaries.full","ls");
pref("extensions.alpheios.latin.dictionary.full.search.url",
     "http://repos.alpheios.net:8080/exist/rest/db/xq/lexi-get.xq?lx=<LEXICON>&lg=lat&out=html");
pref("extensions.alpheios.latin.dictionary.full.search.lemma_param","l");
pref("extensions.alpheios.latin.dictionary.full.search.id_param","n");
pref("extensions.alpheios.latin.dictionary.full.search.multiple",true);
pref("extensions.alpheios.latin.sites.autoenable","http://www.thelatinlibrary.com,http://thelatinlibrary.com");
