Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "agarwal_software#index"
  post "uploadqcdn" => "agarwal_software#uploadqcdn"
  post "uploadjk" => "agarwal_software#uploadjk"
  get "compare" => "agarwal_software#compare"
  get "agarwal_software/compare1"
  get "compare_product" => "agarwal_software#compare_product"
  get "agarwal_software/compare_product1"
end
