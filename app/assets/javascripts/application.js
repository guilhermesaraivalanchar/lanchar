// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require jquery/jquery.min
//= require jquery.slimscroll
//= require popper/popper.min
//= require bootstrap/js/bootstrap.min
//= require custom.min
//= require sidebarmenu
//= require waves
//= require sparkline/jquery.sparkline.min
//= require sticky-kit-master/dist/sticky-kit.min
//= require custom.js.coffee
//= require perfect-scrollbar.min
//= require jquery.mask
//= require jquery.validate
//= require moment/min/moment-with-locales
//= require bootstrap-material-datetimepicker/js/bootstrap-material-datetimepicker
//= require bootstrap-datepicker.min
//= require bootstrap-datepicker.pt-BR.min
//= require bootstrap-datetimepicker
//= require bootstrap-datetimepicker.pt-BR
//= require datatables/datatables.min
//= require dataTables.buttons.min
//= require datatables-plugins/api/sum()
//= require buttons.flash.min
//= require jszip.min
//= require pdfmake.min
//= require vfs_fonts
//= require buttons.html5.min
//= require buttons.print.min
//= require dropify/dist/js/dropify.min
//= require select2/dist/js/select2.full.min.js
//= require bootstrap-select/bootstrap-select.min.js
//= require multiselect/js/jquery.multi-select.js
//= require cocoon
//= require jquery.maskMoney
//= require daterangepicker/daterangepicker
//= require sweetalert/sweetalert.min
//= require chartist-js/dist/chartist.min.js
//= require chartist-plugin-tooltip-master/dist/chartist-plugin-tooltip.min.js
//= require flot/excanvas.js
//= require flot/jquery.flot.js
//= require flot/jquery.flot.pie.js
//= require flot.tooltip/js/jquery.flot.tooltip.min.js
//= require vectormap/jquery-jvectormap-2.0.2.min.js
//= require vectormap/jquery-jvectormap-us-aea-en.js

function toggle_menu(){
  $("body").toggleClass("show-sidebar");
}
$(document).ready(function() {


  $('.botao_filtro').click(function(){
    $(".div_filtro").toggle();
    $('.chosen-select').select2();
  })

  $("form").validate({
    errorClass: "validate_invalid",
    validClass: "validate_valid",
    invalidHandler: function(event, validator) {
      var lista_erro = ""
      var erros = [];
      var num_erros = 0;
      for(i in validator.errorList){
        add_erro = "<br><b>" + validator.errorList[i].element.getAttribute("nome_validacao") + "</b>: "+ validator.errorList[i].message;
        if (erros.indexOf(add_erro) == -1){
          lista_erro = lista_erro + add_erro;
          num_erros++;
          erros.push(add_erro);
        }
      }
      var errors = validator.numberOfInvalids();
      if (errors) {
      $("div.error_validate span").html('<b style="font-size: 20px">Foram encontrado(s) ' + num_erros + ' erro(s):</b> <br>' + lista_erro);
      $("div.error_validate").show();
      } else {
        $("div.error_validate").hide();
      }
    },
    messages: {
      "veiculo[tipo_veiculo_id]": {
        remote: "Tipo Veiculo Inexistente."
      },
      "transporte[cpf_motorista]": {
        remote: "Motorista com pendências ou inexistente."
      }
    }
  });


  $(".datetimepicker_range").setMask("39/19/9999 99:99")
  
  $('.datetimepicker_range').daterangepicker({
    "singleDatePicker": true,
    "timePicker": true,
    autoUpdateInput: false,
    "timePicker24Hour": true,
    "startDate": false,
    locale: {
      format: 'DD/MM/YYYY HH:MM',
      cancelLabel: 'Cancelar',
      applyLabel: 'Confirmar'
    }
  });

  $('.datetimepicker_range').on('apply.daterangepicker', function(ev, picker) {
    $(this).val(picker.startDate.format('DD/MM/YYYY HH:mm'))
    
    //$(this).val(picker.startDate.format('MM/DD/YYYY') + ' - ' + picker.endDate.format('MM/DD/YYYY'));
  });

});

function number_to_currency(number, options) {
  try {
    var options = options || {};
    var precision = options["precision"] || 2;
    var unit = options["unit"] || "\u20AC";
    var separator = precision > 0 ? options["separator"] || "." : "";
    var delimiter = options["delimiter"] || ",";
    var parts = parseFloat(number).toFixed(precision).split('.');

    return unit + number_with_delimiter(parts[0], delimiter) + separator + parts[1].toString();

  } catch(e) {
    return number;
  }
}

 

function number_with_delimiter(number, delimiter, separator) {
  try {
    var delimiter = delimiter || ",";
    var separator = separator || ".";
    var parts = number.toString().split('.');
    parts[0] = parts[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1" + delimiter);
    
    return parts.join(separator);
    
  } catch(e) {
    return number
  }
}

