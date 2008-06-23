pref("extensions.alpheios.latin.usemhttpd", true);
pref("extensions.alpheios.latin.chromepkg","alpheios-latin");
pref("extensions.alpheios.latin.languagecode","la");
pref("extensions.alpheios.latin.base_unit","word");
pref("extensions.alpheios.latin.shift_handler","handleInflections");
pref("extensions.alpheios.latin.context_handler","grammarContext");
pref("extensions.alpheios.latin.methods.convert",'latin_to_ascii');
pref("extensions.alpheios.latin.methods.lexicon",'webservice');
pref("extensions.alpheios.latin.url.lexicon", 'http://localhost:8200');
pref("extensions.alpheios.latin.url.lexicon.request", "/latin?word=<WORD>");
pref("extensions.alpheios.latin.url.lexicon.timeout",5000);
pref("extensions.alpheios.latin.url.grammar",
     "chrome://alpheios-latin/content/alph-latin-grammar.xul");
pref("extensions.alpheios.latin.grammar.hotlinks",
     "alph-decl,alph-conj,alph-pofs,alph-mood,alph-case");
pref("extensions.alpheios.latin.popuptrigger",'dblclick');
pref("extensions.alpheios.latin.cmds.alpheios-inflect-cmd","handleInflections");
pref("extensions.alpheios.latin.cmds.alpheios-morph-inflect-cmd","handleInflectionsForMorphWindow");
pref("extensions.alpheios.latin.cmds.alpheios-grammar-cmd","openGrammar");
            