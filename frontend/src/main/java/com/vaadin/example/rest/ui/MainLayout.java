package com.vaadin.example.rest.ui;

import com.vaadin.flow.component.applayout.AppLayout;
import com.vaadin.flow.component.applayout.DrawerToggle;
import com.vaadin.flow.component.dependency.CssImport;
import com.vaadin.flow.component.html.H1;
import com.vaadin.flow.component.html.Header;
import com.vaadin.flow.component.html.ListItem;
import com.vaadin.flow.component.html.Nav;
import com.vaadin.flow.component.html.UnorderedList;
import com.vaadin.flow.router.AfterNavigationEvent;
import com.vaadin.flow.router.AfterNavigationObserver;
import com.vaadin.flow.router.RouterLink;

/**
 * Example application that demonstrates how to Use Spring to fetch data from a
 * REST source and how to show it in a Vaadin Grid.
 * <p>
 * 3rd party data is fetched from https://jsonplaceholder.typicode.com/ using
 * our {@link RestClientService) class.
 */
@CssImport("./styles/shared-styles.css")
public class MainLayout extends AppLayout implements AfterNavigationObserver {

	private final H1 pageTitle;



	public MainLayout() {
		// Navigation
		//home = new RouterLink("Song Recommendation Service", HomeView.class);
		
		//final UnorderedList list = new UnorderedList(new ListItem(home));
		//final Nav navigation = new Nav(list);
		//addToDrawer(navigation);
		//setPrimarySection(Section.DRAWER);
		//setDrawerOpened(false);

		// Header
		pageTitle = new H1("Song Recommendation Service");
		pageTitle.getStyle().set("font-size", "3em");
		final Header header = new Header(new DrawerToggle(), pageTitle);
		pageTitle.getStyle().set("color", "white");
		header.getStyle().set("height", "80px");
		
		header.getElement().getClassList().add("header-background");
		addToNavbar(header);
	}


	@Override
	public void afterNavigation(AfterNavigationEvent event) {

	}
}
