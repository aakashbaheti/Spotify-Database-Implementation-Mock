# Spotify-Database-Implementation-Mock

I built a database system for the music streaming industry, using Spotify as an example. It stores and manages user data such as listening habits, playlists, genre preferences, and demographics from the Spotify platform. The primary goal was to enhance the user experience through data analysis, enabling personalized recommendations, intelligent playlists, and other services. The data also provides valuable insights for Spotify analysts, curators, and artists to understand user preferences for product and marketing decisions.

During the design stage, I learned how different design decisions influence how data is understood in the context of a database. For example, I initially considered streams as an entity set but realized through feedback and experience that streams function better as a relationship between users and songs, implemented as a table. I also made decisions about the kinds of data to represent to align with the predicted use cases and designed the ERD with queries and business needs in mind.

In the implementation stage, I thoughtfully translated the ERD into a relational database, troubleshooting check constraints and triggers to ensure logical and informed decisions. Having a solid understanding of the database structure and relationships made query building more straightforward, allowing me to implement a robust set of queries that showcased the database’s use cases.

While successful overall, I encountered challenges, such as determining appropriate check constraints in create table statements and implementing feedback from Professor Lucy Wang and peers without conflicting with project requirements. Additionally, revisiting Figma for the ERD after some time presented a learning curve. I addressed redundancy and consistency challenges by revising the ERD structure, adding or removing attributes where necessary, and ensuring the insert statements aligned with create table statements to prevent conflicts across database schemas.

Sources: 

https://www.timjoo.com/spotify

https://www.w3schools.com/sql/sql_ref_sqlserver.asp
