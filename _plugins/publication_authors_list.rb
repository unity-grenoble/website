module Jekyll
    module PublicationAuthorsList
      def publication_authors_list(input)
        "Hello World"
      end
    end
  end
  
  Liquid::Template.register_filter(Jekyll::PublicationAuthorsList)