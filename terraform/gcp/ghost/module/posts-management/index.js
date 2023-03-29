const GhostAdminAPI = require('@tryghost/admin-api');
const GhostContentAPI = require('@tryghost/content-api');
const functions = require('@google-cloud/functions-framework');

// Register a CloudEvent function with the Functions Framework
functions.cloudEvent('removeAllPosts', cloudEvent => {
  const ghostUrl = process.env.GHOST_URL
  const adminKey = process.env.GHOST_ADMIN_KEY
  const contentKey = process.env.GHOST_CONTENT_KEY

  const adminApi = new GhostAdminAPI({
      url: ghostUrl,
      key: adminKey,
      version: "v5.0",
    });

  const contentApi = new GhostContentAPI({
    url: ghostUrl,
    key: contentKey,
    version: "v5.0"
  });

  contentApi.posts
    .browse({limit: 'all'})
    .then((posts) => {
      posts.forEach((post) => {
          adminApi.posts.delete({id: post.id})
          .then(res => console.log(`Successful delete of post with id: ${post.id}, API response: ${JSON.stringify(res)}`))
          .catch(err => console.log(err));
      });
    })
    .catch((err) => {
      console.error(err);
    });
});
