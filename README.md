# gif_search_app

Flutter 3.27.1

## Technical requirements:

- ✅ Primary platforms - Android: Tested extensively
- ➖ Primary platforms - iOS: Not tested. I did try to adjust the app for iOS however I could (for example, creating the app icons for iOS as well), but since I currently do not have access to an Apple device, testing the app on iOS becomes incredibly difficult. I did create an .ipa file of the app using CodeMagic, and then tried to test the app with Appium on AWS Device Farm, but I kept running into issues and after a long time trying decided that it would be better to just leave it be and explain my situation here. If I had access to an Apple device, I would have loved to test the app thoroughly.
- ✅ Auto search: requests to retrieve Gif information from the service are made automatically with a small delay after user stops typing
- ✅ Pagination: loads more results when scrolling
- ✅ Vertical & horizontal orientation support
- ✅ Error handling
- ✅ 12 unit tests

## UI:

- ✅ Responsive & matching platform guidelines
- ✅ 2 views sourced by data from Giphy
- ✅ Results are displayed in a grid
- ✅ Clicking on a grid item navigates to a detailed Gif view
- ✅ Loading indicators
- ✅ Error display

## Bonus Points:

- ✅ Using a state management library - Riverpod
- ✅ Using an understandable architecture pattern
- ✅ Page navigation is separate from page widget code
- ✅ Network availability handling

## About my experience developing the app:

I do have to say, creating the app for the past 6 days (about 40 hours) has been an incredibly fun experience for me. I had no prior experience with app development, so it was a new and exciting challenge. I'm almost saddened by the fact that I have to return to React, though there are definitely aspects of React that I prefer over Flutter React than I do with Flutter - like the availability of Tailwind, which makes designing apps on the go far less frustrating.
Making the app from scratch gave me valuable insights into how app development differs from web development to which I'm used to. That said, I would definitely like to add more things to the app and make it more complete, just as a hobby. For instance, I couldn't quite figure out how to prewarm animations (both the splash screen and the initial transition animation) so that they don't appear laggy or get skipped entirely. I’d also love to work on improving the layout and exploring how a bottom tab could be implemented.
Still, it was an incredible experience. With my current knowledge I could make the same app much faster, though it would be far more interesting for me to get my hands on implementing new features.
