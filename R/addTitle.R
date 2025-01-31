#' AddTitle
#'
#' https://github.com/Lchiffon/leafletCN/blob/master/R/addTitle.R
#' 
#' @export
addTitle = function(object,
                    text,
                    color = "black",
                    fontSize = "20px",
                    fontFamily = "Sans",
                    leftPosition = 50,
                    topPosition = 2){

  htmlwidgets::onRender(object, paste0("
                                       function(el,x){
                                       h1 = document.createElement('h1');
                                       h1.innerHTML = '", text ,"';
                                       h1.id='titleh1';
                                       h1.style.color = '", color ,"';
                                       h1.style.fontSize = '",fontSize,"';
                                       h1.style.fontFamily='",fontFamily,"';
                                       h1.style.position = 'fixed';
                                       h1.style['-webkit-transform']='translateX(-50%)';
                                       h1.style.left='",leftPosition ,"%';
                                       h1.style.top='",topPosition,"%';
                                       document.body.appendChild(h1);
                                       }"))
}

