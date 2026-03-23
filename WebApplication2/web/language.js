
function setLanguage(lang){
    localStorage.setItem("siteLang", lang);
    document.cookie = "googtrans=/en/" + lang;
    location.reload();
}

window.onload = function(){
    let lang = localStorage.getItem("siteLang");
    if(lang){
        document.cookie = "googtrans=/en/" + lang;
    }
};