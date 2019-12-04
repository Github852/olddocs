class WebsiteController < ApplicationController

  before_action {
    build_menu
  }

  def index

  end

  def template
    path = params[:path]
    root_path = "website/templates"

    @menu_structure.each do |section|
      section[:pages].each do |page|
        if page[:path] == path
          if page[:template]
            @template_path = "#{root_path}/#{page[:template]}"
          elsif page[:markdown]
            @template_content = render_markdown_file(page[:markdown])
          end
          @title = page[:title]
        end
      end
    end

  end

  private

  def build_menu
    @menu_structure = [
      {
        title: "Self Hosting",
        pages: [
          {
            title: "Getting Started with Self Hosting",
            markdown: "self-hosting/getting-started.md"
          },
          {
            title: "Self Hosting with EC2 and Nginx",
            markdown: "self-hosting/ec2-nginx.md"
          },
          {
            title: "Self Hosting with Docker",
            markdown: "self-hosting/docker.md"
          },
          # {
          #   title: "Self Hosting on AWS with a Preconfigured Image",
          #   markdown: "self-hosting/preconfigured-image.md"
          # },
          {
            title: "Self Hosting with Heroku",
            markdown: "self-hosting/heroku.md"
          }
        ]
      },
      {
        title: "Extensions",
        pages: [
          {
            title: "Intro to Extensions",
            markdown: "extensions/intro.md"
          },
          {
            title: "Building an Extension",
            markdown: "extensions/building-an-extension.md"
          },
          {
            title: "Local Setup",
            markdown: "extensions/local-setup.md"
          },
          {
            title: "Themes",
            markdown: "extensions/themes.md"
          },
          {
            title: "Actions",
            markdown: "extensions/actions.md"
          },
          {
            title: "Publishing",
            markdown: "extensions/publishing.md"
          },
        ]
      },

      {
        title: "Specification",
        pages: [
          {
            title: "Encryption",
            markdown: "specification/encryption.md"
          },
          {
            title: "Sync",
            markdown: "specification/sync.md"
          }
        ]
      }
    ]

    compute_paths_for_structure(@menu_structure)
  end


  def render_markdown_file(path)
    absolute_path = "#{Rails.root}/app/views/website/markdown/#{path}"
    file_content = File.read(absolute_path)
    options = {
      filter_html:     false,
      hard_wrap:       true,
      link_attributes: { target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true,
      prettify: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true,
      fenced_code_blocks: true,
      lax_spacing: true,
      tables: true,
      footnotes: true,
      highlight: true
    }

    renderer = CustomRender.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    return markdown.render(file_content).html_safe
  end

  def compute_paths_for_structure(structure)
    structure.each do |section|
      section[:pages].each do |page|
        path = "#{section[:title].parameterize}/#{page[:title].parameterize}"
        page[:path] = path
      end
    end
  end

end

class CustomRender < Redcarpet::Render::HTML
  require 'rouge'
  require 'rouge/plugins/redcarpet'
  include Rouge::Plugins::Redcarpet
end
