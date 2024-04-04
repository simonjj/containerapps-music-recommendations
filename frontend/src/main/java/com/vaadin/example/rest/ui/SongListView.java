package com.vaadin.example.rest.ui;

import org.springframework.beans.factory.annotation.Autowired;

import com.vaadin.example.rest.data.Song;
import com.vaadin.example.rest.data.SongRestService;
import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.textfield.TextField;
import com.vaadin.flow.component.button.ButtonVariant;
import com.vaadin.flow.component.grid.Grid;
import com.vaadin.flow.component.html.Main;
import com.vaadin.flow.router.PageTitle;
import com.vaadin.flow.router.Route;
import com.vaadin.flow.data.provider.ListDataProvider;
import com.vaadin.flow.data.provider.DataProvider;
import java.util.List;
import com.vaadin.flow.data.renderer.ComponentRenderer;

@PageTitle("List Songs")
@Route(value = "songview", layout = MainLayout.class)
public class SongListView extends Main {
    private Grid<Song> songsGrid;

	public SongListView(@Autowired SongRestService service) {
		// First example uses a Data Transfer Object (DTO) class that we've created. The
		// Vaadin Grid works well with entity classes, so this is quite straightforward:
		songsGrid = new Grid<Song>(Song.class);
        List<Song> songs = service.getAllSongs();
        songsGrid.setItems(songs);
        songsGrid.setColumns("ids", "name", "artist", "genre", "score");
        Grid.Column<Song> score_col = songsGrid.getColumnByKey("score");
        Grid.Column<Song> ids_col = songsGrid.getColumnByKey("ids");
        score_col.setVisible(false);
        ids_col.setVisible(false);

        TextField searchField = new TextField();
        searchField.getStyle().set("width", "50%");
        searchField.getStyle().set("margin", "0 auto");
        searchField.setPlaceholder("Search...");

        ListDataProvider<Song> dataProvider = DataProvider.ofCollection(songs);
        songsGrid.setDataProvider(dataProvider);

        searchField.addValueChangeListener(event -> {
            String searchTerm = event.getValue().toLowerCase();
            if (searchTerm.isEmpty()) {
                dataProvider.clearFilters();
                return;
            }
            dataProvider.addFilter(song -> 
                song.getName().toLowerCase().contains(searchTerm) ||
                song.getArtist().toLowerCase().contains(searchTerm) ||
                song.getGenre().toLowerCase().contains(searchTerm)
            );
        });

        add(searchField, songsGrid);
	}

    public Grid<Song> getGrid() {
        return songsGrid;
    }
}
