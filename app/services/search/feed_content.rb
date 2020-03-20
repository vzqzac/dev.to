module Search
  class FeedContent < Base
    INDEX_NAME = "feed_content_#{Rails.env}".freeze
    INDEX_ALIAS = "feed_content_#{Rails.env}_alias".freeze
    MAPPINGS = JSON.parse(File.read("config/elasticsearch/mappings/feed_content.json"), symbolize_names: true).freeze
    DEFAULT_PAGE = 0
    DEFAULT_PER_PAGE = 60

    class << self
      def search_documents(params:)
        set_query_size(params)
        query_hash = Search::QueryBuilders::FeedContent.new(params).as_hash

        results = search(body: query_hash)
        hits = results.dig("hits", "hits").map do |feed_doc|
          prepare_doc(feed_doc)
        end
        paginate_hits(hits, params)
      end

      private

      # def prepare_doc(hit)
      #   hit.dig("_source", "class_name") == "Article" ? prepare_article_doc(hit) : prepare_podcast_doc(hit)
      # end

      # title: "Testing Post"
      # tag_list: (3) ["cool", "java", "help"]
      # id: 35
      # reading_time: 1
      # comments_count: 0
      # positive_reactions_count: 0
      # path: "/mstruve/testing-post-b0n"
      # class_name: "Article"
      # readable_publish_date: "Feb 10"
      # flare_tag: {name: "help", bg_color_hex: null, text_color_hex: null}
      # user: {username: "mstruve", name: "Molly Struve", profile_image_90: "/uploads/user/profile_image/11/5bfbc285-fb2a-4f5c-a97b-c3e5d80c3d7d.jpeg", pro: true}
      # objectID: "articles-35"
      # _snippetResult:
      # comments_blob: {value: "", matchLevel: "none"}
      # body_text:
      # value: ""↵All articles and discussions should be about the <em>Ruby</em> programming language and related frameworks and technologies like Rails"
      # matchLevel: "full"

      def prepare_doc(hit)
        source = hit.dig("_source")
        source["id"] = hit.dig("_source", "id").split("_").last.to_i
        source["tag_list"] = hit.dig("_source", "tags")&.map { |t| t["name"] } || []
        source["flare_tag"] = hit.dig("_source", "flare_tag_hash")
        source["user_id"] = hit.dig("_source", "user", "id")
        published_at_timestamp = DateTime.parse(hit.dig("_source", "published_at"))
        source["published_at_int"] = published_at_timestamp.to_i
        source["published_timestamp"] = published_at_timestamp
        source["highlight"] = hit["highlight"]
        source
      end

      # id: 49020,
      #   title: 'monitor recontextualize',
      #   path: '/some-post/path',
      #   type_of: '',
      #   class_name: 'PodcastEpisode',
      #   flare_tag: {
      #     id: 58676,
      #     name: 'javascript',
      #     hotness_score: 99,
      #     points: 23,
      #     bg_color_hex: '#000000',
      #     text_color_hex: '#ffffff',
      #   },
      #   tag_list: ['javascript', 'ruby', 'go'],
      #   cached_tag_list_array: [],
      #   user_id: 27683,
      #   user: {
      #     username: 'Nova_Luettgen',
      #     name: 'Henri Gibson',
      #     profile_image_90: '/images/10.png',
      #   },
      #   published_at_int: 1582038662478,
      #   published_timestamp: 'Tue, 18 Feb 2020 15:11:02 GMT',
      #   readable_publish_date: 'February 18',
      # def prepare_podcast_doc(hit)
      #   source = hit.dig("_source")
      #   source["tag_list"] = hit["tags"]&.map{|t| t["name"]} || []
      #   source["user_id"] = source.dig("user", "id")
      #   source["highlight"] = hit["highlight"]
      #   source
      # end

      def index_settings
        if Rails.env.production?
          {
            number_of_shards: 10,
            number_of_replicas: 1
          }
        else
          {
            number_of_shards: 1,
            number_of_replicas: 0
          }
        end
      end
    end
  end
end
