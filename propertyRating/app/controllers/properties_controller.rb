class PropertiesController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  # GET /properties
  # GET /properties.json
  def index
    @properties = Property.all
    if params[:search]
      if params[:search_criteria] == "address"
        @properties = Property.searchAddress(params[:search]).order("created_at DESC")
      elsif params[:search_criteria] == "city"
        @properties = Property.searchCity(params[:search]).order("created_at DESC")
      elsif params[:search_criteria] == "zip"
        @properties = Property.searchZip(params[:search]).order("created_at DESC")
      end
    else
    @properties = Property.all.order('created_at DESC')
    end
  end
 
  # GET /properties/1
  # GET /properties/1.json
  def show
  end

  # GET /properties/new
  def new
    @property = Property.new
  end

  # GET /properties/1/edit
  def edit
  end

  # POST /properties
  # POST /properties.json
  def create
    @property = Property.new(property_params)
    flash[:notice] = ""
    
    AddressValidator.configure do |config|
          config.key = 'FCED759B3311FF22'
          config.username = 'admin'
          config.password = 'admin'
        end

        addressToCheck = AddressValidator::Address.new(
          name: 'John Doe', #The UPS API requires a name attribute
          street1: @property.address,
          city: @property.city,
          state: @property.state,
          zip: @property.zip,
          country: 'US'
        )

        validator = AddressValidator::Validator.new
        response = validator.validate(addressToCheck)

      if response.valid?
        respond_to do |format|
          if @property.save
            format.html { redirect_to @property, notice: 'Thank you! Your property was successfully added.' }
            format.json { render :show, status: :created, location: @property }
          else
            format.html { render :new }
            format.json { render json: @property.errors, status: :unprocessable_entity }
          end
        end
      elsif response.ambiguous?
        flash[:notice] = "Sorry, that address is too ambiguous. Please try again."
        redirect_to :back
      elsif response.no_canidates?
        flash[:notice] = "Sorry, that address is not valid. Please try again."
        redirect_to :back
      end
  end

  # PATCH/PUT /properties/1
  # PATCH/PUT /properties/1.json
  def update
    respond_to do |format|
      if @property.update(property_params)
        format.html { redirect_to @property, notice: 'Property was successfully updated.' }
        format.json { render :show, status: :ok, location: @property }
      else
        format.html { render :edit }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.json
  def destroy
    @property.destroy
    respond_to do |format|
      format.html { redirect_to properties_url, notice: 'Property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_property
      @property = Property.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def property_params
      params.require(:property).permit(:address, :apt, :city, :state, :zip)
    end
end
