package com.vaadin.example.rest.ui;

import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import com.vaadin.flow.component.splitlayout.SplitLayout;
import com.vaadin.example.rest.data.Song;
import com.vaadin.example.rest.data.SongRestService;
import com.vaadin.flow.component.Component;

import org.springframework.beans.factory.annotation.Autowired;


@PageTitle("Songs")
@Route(value = "", layout = MainLayout.class)
public class SongsMain extends VerticalLayout {

    public SongsMain(@Autowired SongRestService service) {

        SplitLayout masterSplit = new SplitLayout();
        masterSplit.setOrientation(SplitLayout.Orientation.VERTICAL);
        masterSplit.setSizeFull();
        masterSplit.setSplitterPosition(100);
        //masterSplit.setVisible(false);

        SplitLayout splitLayout = new SplitLayout();
        splitLayout.setSizeFull();
        splitLayout.setSplitterPosition(100);
        //splitLayout.setVisible(false);

        RecommendationsView recommendationsView = new RecommendationsView();
        recommendationsView.setVisible(false);

        SongListView songListView = new SongListView(service);
        SongDetailView songDetailView = new SongDetailView(splitLayout, service, recommendationsView, masterSplit);
        songDetailView.setVisible(false);

        songListView.getGrid().addItemClickListener(event -> {
            songDetailView.setSong(event.getItem());
            splitLayout.setSplitterPosition(70);
            songDetailView.setVisible(true); // Show the SongDetailView when a row is clicked
        });

        splitLayout.addToPrimary(songListView);
        splitLayout.addToSecondary(songDetailView);

        masterSplit.addToPrimary(splitLayout);
        masterSplit.addToSecondary(recommendationsView);
        add(masterSplit);
    }
}