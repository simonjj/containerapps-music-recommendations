package com.vaadin.example.rest.data;

import java.io.Serializable;
import java.util.List;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClient.RequestHeadersSpec;


import com.fasterxml.jackson.databind.JsonNode;
import com.vaadin.flow.data.provider.DataProvider;
import com.vaadin.example.rest.util.Utils;


/**
 * Example Spring service that connects to a REST API.
 * <p>
 * The class has three different examples for fetching data.
 * <p>
 * {@link #getAllComments()} uses a DTO class to map the JSON results from a 3rd
 * party API. It fetches all available results immediately.
 * <p>
 * {@link #getAllPosts()} does not use a DTO for the results, but lets the user
 * process the result JSON in the UI class instead. It fetches all available
 * results immediately.
 * <p>
 * {@link #fetchData(int, int)} and {@link #fetchCount()} demonstrate the two
 * methods needed for creating Lazy {@link DataProvider}s, where we don't fetch
 * all results immediately, but only a portion at a time. This is done to reduce
 * unnecessary memory consumption.
 */
@SuppressWarnings("serial")
@Service
public class SongRestService implements Serializable {

	/**
	 * The port changes depending on where we deploy the app
	 */


	/**
	 * Returns parsed {@link CommentDTO} objects from the REST service.
	 *
	 * Useful when the response data has a known structure.
	 */
	public List<Song> getAllSongs() {

		System.out.println("Fetching all Songs objects through REST..");

		// Fetch from 3rd party API; configure fetch
		final RequestHeadersSpec<?> spec = WebClient.create().get()
				.uri(Utils.getBackendServer()+ "/songs");

		// do fetch and map result
		final List<Song> songs = spec.retrieve().toEntityList(Song.class).block().getBody();

		System.out.println(String.format("...received %d items.", songs.size()));

		return songs;
	}

    public List<Song> getRecommendedSongs(String id) {
        System.out.println("Fetching recommended Songs objects through REST..");

        // Fetch from 3rd party API; configure fetch
        final RequestHeadersSpec<?> spec = WebClient.create().get()
                .uri(Utils.getBackendServer()+ "/songs/recommend/" + id);

        // do fetch and map result
        final List<Song> songs = spec.retrieve().toEntityList(Song.class).block().getBody();

        System.out.println(String.format("...received %d items.", songs.size()));

        return songs;
    }


}