# -*- coding: utf-8 -*-
class Gist2RssController < ApplicationController
  require 'open-uri'
  require 'json'
  def plain
    @user = params[:user]
    gistsJsonStr = URI.parse("https://api.github.com/users/#{@user}/gists").read;
    @gistsJson = JSON.parse(gistsJsonStr)
    @contents = Hash::new
    @gistsJson.each do |j|

      # Railsでcache (Rails.cache.fetch)
      # http://blog.twiwt.org/e/ff4c23
      # キャッシュの種類は、デフォルトはファイルキャッシュ
      # ファイルキャッシュの場所はtmp/cache/以下
      # 切り替えるには、config/environments/production.rb 等で"config.cache_store"を書き換える
      gistID = j['id']
      @contents[gistID] = Rails.cache.fetch( gistID, :expires_in => 1.hour) do
        rawURL = j['files'][ j['files'].keys[0] ]['raw_url']
        { "raw" => URI.parse(rawURL).read };
      end
      
    end
    
    render "gist2_rss/atom.xml.erb"
  end
end
