package com.vaadin.example.rest.ui;

import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.html.Label;
import java.util.List;
import com.vaadin.flow.component.html.H3;
import com.vaadin.example.rest.data.Song;
import com.vaadin.flow.component.html.Div;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.FlexComponent.Alignment;
import com.vaadin.example.rest.util.Utils;

public class RecommendationsView extends Div {

    private HorizontalLayout layout;

    public RecommendationsView() {
        Button closeButton = new Button(VaadinIcon.CLOSE.create(), clickEvent -> this.setVisible(false));
        H3 title = new H3("Song Recommendations");
        HorizontalLayout header = new HorizontalLayout(closeButton, title);
        header.expand(title);
        header.setVerticalComponentAlignment(Alignment.CENTER, closeButton, title);

        layout = new HorizontalLayout();
        layout.getStyle().set("overflow-x", "auto");
        layout.getStyle().set("white-space", "nowrap");
        add(header, layout);
    }

    public void setSongs(List<Song> songs) {
        layout.removeAll();
        for (Song song : songs) {
            VerticalLayout songLayout = new VerticalLayout();
            Label nameLabel = new Label(song.getName());
            nameLabel.getStyle().set("font-weight", "bold");
            Label artistLabel = new Label(song.getArtist());
            Label genreLabel = new Label(song.getGenre());
            Label scoreLabel = new Label(song.getScore());
            AudioPlayer audioPlayer = new AudioPlayer();
            audioPlayer.setSource(Utils.getBackendServer()+ "/songs/play/" + song.getIds());
            songLayout.add(nameLabel, artistLabel, genreLabel, scoreLabel, audioPlayer);
            layout.add(songLayout);
        }
    }
}