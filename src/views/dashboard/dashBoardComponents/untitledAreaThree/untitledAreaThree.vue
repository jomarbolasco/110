<script>
import axios from 'axios'

export default {
  data() {
    return {
      news: [],
      currentSlide: 0,
    }
  },
  methods: {
    async fetchNews() {
      try {
        const response = await axios.get(
          `https://newsapi.org/v2/top-headlines?country=us&category=health&apiKey=${import.meta.env.VITE_NEWSAPI_KEY}`,
        )
        this.news = response.data.articles
          .filter((article) => article.urlToImage) // Filter out articles without images
          .map((article) => ({
            title: article.title,
            description: article.description,
            date: new Date(article.publishedAt).toLocaleDateString(),
            url: article.url,
            imageUrl: article.urlToImage,
          }))
      } catch (error) {
        console.error('Error fetching news:', error)
      }
    },
    nextSlide() {
      this.currentSlide = (this.currentSlide + 1) % this.news.length
    },
  },
  mounted() {
    this.fetchNews()
    setInterval(this.nextSlide, 5000) // Change slide every 5 seconds
  },
}
</script>

<template>
  <v-row>
    <v-col cols="12" lg="4">
      <v-card>
        <v-card-title>
          <v-icon class="mr-2">mdi-newspaper</v-icon>
          News and Updates
        </v-card-title>
        <v-card-text>
          <v-carousel v-model="currentSlide" hide-delimiters height="400px">
            <v-carousel-item v-for="(item, index) in news" :key="index">
              <v-img :src="item.imageUrl" alt="News Image" height="300px"></v-img>
              <v-card-text>
                <v-list-item-title>
                  <a :href="item.url" target="_blank" class="news-title">{{ item.title }}</a>
                </v-list-item-title>
                <v-list-item-subtitle>{{ item.description }}</v-list-item-subtitle>
                <v-list-item-subtitle class="grey--text">{{ item.date }}</v-list-item-subtitle>
              </v-card-text>
            </v-carousel-item>
          </v-carousel>
        </v-card-text>
      </v-card>
    </v-col>
    <v-col cols="12" lg="4">
      <v-card>
        <img style="width: 100%" src="./images/batonghinog.png" />
        <v-card-text>
          <h5 class="title font-weight-medium mb-2 text-h6">System Analyst</h5>
          <p class="mb-3 text-body-2 text-grey-darken-1">
            Some quick example text to build on the card title and make up the bulk of the card's
            content.
          </p>
          <v-btn depressed color="error">Learn More</v-btn>
        </v-card-text>
      </v-card>
    </v-col>
    <v-col cols="12" lg="4">
      <v-card>
        <img style="width: 100%" src="./images/silab.jpg" />
        <v-card-text>
          <h5 class="title font-weight-medium mb-2 text-h6">Frontend Developer</h5>
          <p class="mb-3 text-body-2 text-grey-darken-1">
            Some quick example text to build on the card title and make up the bulk of the card's
            content.
          </p>
          <v-btn depressed color="info">Learn More</v-btn>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>
