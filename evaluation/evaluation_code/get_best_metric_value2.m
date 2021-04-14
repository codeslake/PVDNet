function val = get_best_metric_value2(score,metric,img,kernel)

switch metric
 case 'MSE'
  val = abs(min(score(:)));
 case 'PSNR'       
  val = abs(max(score(:)));
 case 'MSSIM'        
  val = abs(max(score(:)));
 case 'MAD'        
  val = abs(min(score(:)));
 case 'IFC'        
  val = abs(max(score(:)));
 case 'VIF'        
  val = abs(max(score(:)));
end

return