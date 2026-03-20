/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


/* global lang */

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