class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # default: all movies of all ratings
    @movies = Movie.all
    @all_ratings = Movie.ratings
    @ratings_hash = Hash[*@all_ratings.map {|key| [key, 1]}.flatten]
    set_uri=false
    
    if (params[:ratings] != nil)
      @ratings_hash = params[:ratings]
      @movies = @movies.where(:rating => @ratings_hash.keys)
      session[:ratings] = @ratings_hash
    else
      if(session[:ratings]!=nil)
        @ratings_hash=session[:ratings]
        @movies = @movies.where(:rating => @ratings_hash.keys)
        set_uri=true
      end
    end
    
    @sorttype=params[:sort]
    if(params[:sort]!=nil)
      session[:sort]=params[:sort]
      if(params[:sort]=="title")
        @movies = @movies.order(:title)
        @title = "hilite"
      end
      if(params[:sort]=="date")
        @movies = @movies.order(:release_date)
        @date = "hilite"
      end
    else
      if(session[:sort] != nil)
        params[:sort]=session[:sort]
        set_uri=true
        case params[:sort]
        when "title"
          @movies = @movies.order(:title)
          @title = "hilite"
        when "date"
          @movies = @movies.order(:release_date)
          @date = "hilite"
        end
      end
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
