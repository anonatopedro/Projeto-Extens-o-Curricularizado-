package br.com.sigas.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.sigas.entities.Operacoes;
import br.com.sigas.repositories.OperacoesRepository;

import jakarta.transaction.Transactional;

@Service
public class OperacoesService {

    @Autowired
    private OperacoesRepository operacoesRepository;

    @Transactional
    public void inserirOperacao(Operacoes operacao, Long id_pessoa) {
        operacoesRepository.inserirOperacao(
                operacao.getPessoa().getId_pessoa(),
                operacao.getTipo_operacao(),
                operacao.getData_operacao());
    }

    public Operacoes buscarOperacaoPorId(Integer id) {
        return operacoesRepository.buscarOperacaoPorId(id);
    }

    public List<Operacoes> buscarOperacoesPorPessoa(Long id) {
        return operacoesRepository.buscarOperacoesPorPessoa(id);
    }

    @Transactional
    public void atualizarOperacao(Integer id, Operacoes operacaoAtualizada) {
        operacoesRepository.atualizarOperacao(
                id,
                operacaoAtualizada.getPessoa().getId_pessoa(),
                operacaoAtualizada.getTipo_operacao(),
                operacaoAtualizada.getData_operacao());
    }

    @Transactional
    public void deletarOperacao(Integer id) {
        operacoesRepository.deletarOperacao(id);
    }

}
