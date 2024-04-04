package com.vaadin.example.rest.ui;

import com.vaadin.flow.component.Component;
import com.vaadin.flow.component.Tag;

@Tag("audio")
public class AudioPlayer extends Component {

    public AudioPlayer(){
        getElement().setAttribute("controls",true);

    }

    public  void setSource(String path){
        getElement().setProperty("src", path);
    }
}