class BusinessesController < ApplicationController

  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @businesses = Business.active.joins(:perks).active.distinct.includes(:business_category)
    @addresses_id = []
    @businesses.each do |business|
      # @addresses_id << [business.id, 0] # BUSINESS MAIN ADDRESS
      business.addresses.shop.each do |address_shop|
        @addresses_id << [business.id, address_shop.id]
      end
      if business.itinerant
        business.addresses.active.today.each do |address_itinerant|
           @addresses_id << [business.id, address_itinerant.id]
        end
      end
    end
    @addresses_id.delete([]) # REMOVE WHEN NO ACTIVE RECORD ASSOCIATION
  end

  def show
    # save request.referer when logout access
    if !user_signed_in?
      session[:referer] = request.url
    else
      session.delete(:referer)
    end

    @business = Business.joins(:business_category).find(params[:id])
    @perk = @business.perks.find(params[:perk_id])

    if params[:address_id].to_i > 0
      @address = @business.addresses.find(params[:address_id])
      longitude = @address.longitude
      latitude = @address.latitude
    else
      longitude = @business.longitude
      latitude = @business.latitude
    end

    @geojson = {"type" => "FeatureCollection", "features" => []}

    @geojson["features"] << {
      "type": 'Feature',
      "geometry": {
        "type": 'Point',
        "coordinates": [longitude, latitude],
      },
      "properties": {
        "marker-symbol": @business.business_category.marker_symbol
      }
    }
    respond_to do |format|
      format.html
      format.json{render json: @geojson}
    end
  end
end
