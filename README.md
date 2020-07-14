# Shapr3DFileConverter

This is an app for iPad I created as part of the Shapr3D application exam.

---

Here's what the app does: 

- It shows a list of SHAPR files already added on the left hand side. It is a list composed of a thumbnail image, the name of the file, and the date when it was added. If a third-party format has been exported from the original file, a label is added to the entry indicating it.
- A button on the navigation bar on the left hand side allows you to add more files from outside of the app into the list, importing them into the app. (Note that any file would do: once added, the extension of the file will be renamed to shapr.) You can also access the Edit mode – as well as swipe to delete – to remove files from the app
- Selecting an entry in the list would display the full-sized image on the right hand side of the screen, including some basic information. These images are fake.
- Also on the right hand side view, on the navigation bar you can find the export ('action') button, from which a popup appears where you can choose from among 3 possible formats to export to: STEP, STL, and OBJ. Tapping on any of these options, as long as they're still available, would begin a "mock" export of the file format selected. You can actually run export jobs simultaneously on multiple shapr files.
- You can also access the info popup (from the 'book' icon), to view additional info about the file.
- The app remembers the files added even when you quit it. And if you're starting fresh, the app also adds 5 sample files for you on startup.

### Directions

- Run `pod install` on the project root directory. Open the `.xcworkspace` file afterwards.

### Notes

- I've ran into problems copying some files to use for importing into the Simulator app on Catalina, due to some access restrictions. [This](https://stackoverflow.com/q/58303509) might help.
- I've taken some ideas on how to access document with file system pickers from articles such as [this one on Medium](https://medium.com/flawless-app-stories/a-swifty-way-to-pick-documents-59cad1988a8a).
- This app is iPad-only to reflect the fact that Shapr3D is a primarily iPad product.
- Images display were taken from Unsplash, full credits go to the photographers who took them. I've also lifted images of some 3D models on the internet for a few others.
