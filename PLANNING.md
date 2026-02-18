# CMS for presbyterian church

## 1. Introduction

This document outlines the planning and implementation of a Content Management System (CMS) for a Presbyterian church. The CMS will facilitate the management of events, image galleries, and member details.

## 2. Features

- **Image Gallery**: Upload and manage images for church events and activities.
  - Images should be uploaded and served from Cloudinary, ensuring efficient storage and delivery.
  - Admin needs to be able to upload and select images from Cloudinary, and later reorder them via drag and drop to display images in a specific order.
  - Admin should be able to create multiple galleries, and assign images to specific galleries.
- **Event Management**: Create, edit, and delete events with details such as date, time, location, and description. We also need to able to display events in a calendar view, and have the ability to filter events by date or category. We need the ability to associate an image with each event, which will be displayed on the event details page and in the calendar view. Additionally, we need to be able to display upcoming events (for the current week) on the homepage, and have a separate page for all events.
- **Member Management**: Store and manage member information, including contact details and date of birth. Members are not authorized users, but their information is stored in the database for administrative purposes. Member birthdays for the current month should be displayed on the homepage, and there should be a separate page for all members.

All CRUD related features should only be accessible to authenticated users, ensuring that only authorized personnel can make changes to the content.

We need a way to easily display dates as ordinals (e.g., 1st, 2nd, 3rd) in the event details and member information sections. This will enhance the readability of dates for users.

## 3. Technology Stack

- **Backend**: Ruby on Rails
- **Frontend**: HTML, CSS, JavaScript
  - Consider HTMX or Hotwire for dynamic content updates without full page reloads, especially for the event management and image gallery features.
- **Database**: PostgreSQL
- **Authentication**: Devise gem for user authentication
- **Image Storage**: Cloudinary for efficient image storage and delivery
- **Deployment**: Heroku

## 4. Implementation Plan

1. **Setup Rails Application**: Initialize a new Rails application and configure the database.
2. **User Authentication**: Implement user authentication using Devise to secure the admin functionalities.
3. **Event Management**: Create models, controllers, and views for managing events.
4. **Image Gallery**: Implement the image gallery feature with functionalities for uploading, managing, and organizing images.
5. **Member Management**: Create models, controllers, and views for managing member information.
6. **Testing**: Write tests for all features to ensure functionality and reliability.
7. **Deployment**: Deploy the application to Heroku.
