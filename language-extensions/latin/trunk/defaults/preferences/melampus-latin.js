pref("extensions.melampus.latin.usemhttpd", true);
pref("extensions.melampus.latin.chromepkg","melampus-latin");
pref("extensions.melampus.latin.languagecode","la");
pref("extensions.melampus.latin.base_unit","word");
pref("extensions.melampus.latin.shift_handler","handleInflections");
pref("extensions.melampus.latin.context_handler","grammarContext");
pref("extensions.melampus.latin.methods.convert",'latin_to_ascii');
pref("extensions.melampus.latin.methods.lexicon",'webservice');
pref("extensions.melampus.latin.url.lexicon", 'http://localhost:8200');
pref("extensions.melampus.latin.url.lexicon.request", "/latin?word=<WORD>");
pref("extensions.melampus.latin.url.lexicon.timeout",5000);
pref("extensions.melampus.latin.url.grammar",
     "chrome://melampus-latin/content/mp-latin-grammar.xul");
pref("extensions.melampus.latin.grammar.hotlinks",
     "mp-decl,mp-conj,mp-pofs,mp-mood,mp-case");
pref("extensions.melampus.latin.popuptrigger",'dblclick');
            