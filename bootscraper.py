import requests
from bs4 import BeautifulSoup
import winsound

def scrape_depop_listings():
    url = 'https://www.depop.com/search/?q=dc+snow+boots&priceMax=150&sort=relevance'
    previous_listings = set()  # Track previous listings

    while True:
        # Send an HTTP GET request to the URL
        response = requests.get(url)

        # Create a BeautifulSoup object from the response content
        soup = BeautifulSoup(response.content, 'html.parser')

        # Find all listings on the page
        listings = soup.find_all('div', class_='FeedItem__Content')

        # Extract the title and price for each listing
        for listing in listings:
            title = listing.find('p', class_='FeedItem__title').text.strip()
            price = listing.find('p', class_='Price__price').text.strip()

            # Check if the listing is new
            if title not in previous_listings:
                print('New Listing Detected!')
                print('Title:', title)
                print('Price:', price)
                print('---')

                # Play an alert sound
                winsound.Beep(1000, 500)  # Adjust the frequency and duration as desired

                # Add the listing to the set of previous listings
                previous_listings.add(title)

        # Wait for some time before checking for new listings again (e.g., every 5 minutes)
        time.sleep(300)  # 300 seconds = 5 minutes

scrape_depop_listings()
