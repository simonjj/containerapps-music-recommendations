package com.vaadin.example.rest.ui;

import com.vaadin.flow.component.Component;
import com.vaadin.flow.component.html.Label;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.dom.ElementFactory;
import com.vaadin.example.rest.data.Song;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.html.H3;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.router.RouterLink;
import com.vaadin.example.rest.data.SongRestService;
import com.vaadin.flow.component.splitlayout.SplitLayout;
import com.vaadin.example.rest.util.Utils;

public class SongDetailView extends VerticalLayout {

    private Label idLabel = new Label();
    private Label nameLabel = new Label();
    private Label artistLabel = new Label();
    private Label genreLabel = new Label();
    private Label scoreLabel = new Label();
    private AudioPlayer audioPlayer = new AudioPlayer();
    private Button closeButton = new Button(VaadinIcon.CLOSE.create());
    private Button recommendButton = new Button("Get Song Recommendations");

    private SplitLayout splitLayout;
    private SongRestService service;
    private SplitLayout recommendationsSplit;
    private RecommendationsView recommendationsView;

    public SongDetailView(SplitLayout splitLayout, SongRestService service, 
                          RecommendationsView recommendationsView, SplitLayout recommendationsSplit) {
        this.splitLayout = splitLayout;
        this.service = service;
        this.recommendationsView = recommendationsView;
        this.recommendationsSplit = recommendationsSplit;
        nameLabel.getStyle().set("font-weight", "bold");

        HorizontalLayout header = new HorizontalLayout();
        H3 title = new H3("Song Details");
        header.add(closeButton, title);
        header.expand(title);
        header.setVerticalComponentAlignment(Alignment.CENTER, closeButton, title);

        closeButton.addClickListener(event -> {
            recommendationsView.setVisible(false);
            this.setVisible(false);
        });


        add(header, nameLabel, artistLabel, genreLabel, idLabel, audioPlayer);
    }




    public void setSong(Song song) {
        idLabel.setText("ID: " + song.getIds());
        nameLabel.setText("Name: " + song.getName());
        artistLabel.setText("Artist: " + song.getArtist());
        genreLabel.setText("Genre: " + song.getGenre());
        scoreLabel.setText("Score: " + song.getScore());
        audioPlayer.setSource(Utils.getBackendServer()+ "/songs/play/" + song.getIds());

        recommendButton.addClickListener(clickEvent -> {
            //splitLayout.setSplitterPosition(25);
            recommendationsView.setSongs(service.getRecommendedSongs(song.getIds()));
            recommendationsView.setVisible(true);
        });
        add(recommendButton);
    }
}